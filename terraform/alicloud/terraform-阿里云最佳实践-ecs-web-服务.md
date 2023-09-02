# terraform 阿里云最佳实践 ecs web 服务

使用 terraform 在阿里云上部署一个 web 服务。服务部署在封闭的 vpc 中，通过 slb 对外提供服务。日志自动收集到 sls 中。

## 创建 vpc

```terraform
data "alicloud_zones" "zones_vswitch" {
  available_resource_creation = "VSwitch"
}

# 创建VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = "${var.name}-vpc"
  cidr_block = "172.16.0.0/16"
}

# 创建交换机
resource "alicloud_vswitch" "vswitchs" {
  for_each = {for idx, zone in data.alicloud_zones.zones_vswitch.zones : idx => zone}

  zone_id    = each.value.id
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = cidrsubnet(alicloud_vpc.vpc.cidr_block, 8, each.key)
}

# 创建NAT网关
resource "alicloud_nat_gateway" "nat_gateway" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "${var.name}-nat-gateway"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.vswitchs.0.id
  nat_type         = "Enhanced"
}

# 创建公网IP
resource "alicloud_eip_address" "eip-outbounds" {
  bandwidth            = "5"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
  netmode              = "public"
  isp                  = "BGP"
  address_name         = "tf-test-eip"
}

# 绑定公网IP
resource "alicloud_eip_association" "eip_association_nat_gateway" {
  allocation_id = alicloud_eip_address.eip-outbounds.id
  instance_id   = alicloud_nat_gateway.nat_gateway.id
}

# 等待 eip 和 nat gateway 绑定完成
resource "null_resource" "after_30_seconds_eip_association_nat_gateway" {
  depends_on = [alicloud_eip_association.eip_association_nat_gateway]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# 创建SNAT条目
resource "alicloud_snat_entry" "snat_entry" {
  depends_on = [null_resource.after_30_seconds_eip_association_nat_gateway]

  for_each          = alicloud_vswitch.vswitchs
  snat_table_id     = alicloud_nat_gateway.nat_gateway.snat_table_ids
  source_vswitch_id = each.value.id
  snat_ip           = alicloud_eip_address.eip-outbounds.ip_address
}
```

## 创建 ecs

```terraform
# 服务实例类型
data "alicloud_instance_types" "instance_types" {
  cpu_core_count = 1
  memory_size    = 1
}

# 跳板机实例类型
data "alicloud_instance_types" "instance_types_jump_server" {
  cpu_core_count = 1
  memory_size    = 1
}

# 服务基础镜像
data "alicloud_images" "images_ubuntu_22" {
  name_regex = "^ubuntu_22"
  owners     = "system"
}

# 生成登录秘钥对
resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 保存秘钥
resource "local_file" "file_id_rsa" {
  filename        = "id_rsa"
  content         = tls_private_key.tls_private_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "file_id_rsa_pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tls_private_key.public_key_openssh
}

# 创建秘钥对
resource "alicloud_ecs_key_pair" "ecs_key_pair" {
  key_pair_name = "${var.name}-key-pair"
  public_key    = tls_private_key.tls_private_key.public_key_openssh
}

# 创建安全组
resource "alicloud_security_group" "security_group" {
  name   = "${var.name}-security-group"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "security_group_rule_allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.security_group.id
  cidr_ip           = "123.113.97.7/32"
}

# 创建服务实例（无公网地址）
resource "alicloud_instance" "instances" {
  count           = var.instance_number
  image_id        = data.alicloud_images.images_ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.instance_types.instance_types[0].id
  security_groups = [
    alicloud_security_group.security_group.id,
  ]
  vswitch_id           = alicloud_vswitch.vswitchs[count.index % length(alicloud_vswitch.vswitchs)].id
  internet_charge_type = "PayByTraffic"
  instance_name        = "${var.name}-${count.index + 1}"
  host_name            = "${var.name}-${count.index + 1}"
  key_name             = alicloud_ecs_key_pair.ecs_key_pair.key_pair_name
}

# 等待实例创建完成
resource "null_resource" "after_30_seconds_instance" {
  depends_on = [
    alicloud_instance.instances
  ]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# 创建跳板机
resource "alicloud_instance" "instance_jump_server" {
  image_id        = data.alicloud_images.images_ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.instance_types_jump_server.instance_types[0].id
  security_groups = [
    alicloud_security_group.security_group.id,
  ]
  vswitch_id                 = alicloud_vswitch.vswitchs[0].id
  internet_max_bandwidth_out = 5
  internet_charge_type       = "PayByTraffic"
  instance_name              = "${var.name}-jump-server"
  host_name                  = "${var.name}-jump-server"
  key_name                   = alicloud_ecs_key_pair.ecs_key_pair.key_pair_name

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.public_ip
    private_key = tls_private_key.tls_private_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/id_rsa"
    destination = "/root/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /root/id_rsa"
    ]
  }
}

# 输出连接跳板机的命令
output "connection_jump_server" {
  value = "ssh -i id_rsa root@${alicloud_instance.instance_jump_server.public_ip}"
}

# 创建 OOS 执行所需的 RAM 角色
resource "alicloud_ram_role" "ram_role_oos_service" {
  name     = "${var.name}-oos-service-role"
  force    = true
  document = <<EOF
  {
    "Version": "1",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "oos.aliyuncs.com"
          ]
        }
      }
    ]
  }
  EOF
}

resource "alicloud_ram_role_policy_attachment" "ram_role_policy_attachment_aliyun_ecs_full_access" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.ram_role_oos_service.name
}

# 安装日志服务 agent
resource "alicloud_oos_execution" "oos_execution_install_log_agent" {
  depends_on = [null_resource.after_30_seconds_instance]

  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

  template_name = "ACS-ECS-BulkyInstallLogAgent"
  parameters    = jsonencode({
    regionId = "cn-beijing"
    targets  = {
      Type        = "ResourceIds"
      ResourceIds = [each.value.id]
      RegionId    = "cn-beijing"
    }
    OOSAssumeRole = alicloud_ram_role.ram_role_oos_service.name
  })
}

# 安装云监控 agent
resource "alicloud_oos_execution" "oos_execution_install_cms_agent" {
  depends_on = [null_resource.after_30_seconds_instance]

  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

  template_name = "ACS-ECS-ConfigureCloudMonitorAgent"
  parameters    = jsonencode({
    regionId = "cn-beijing"
    action   = "install"
    targets  = {
      Type        = "ResourceIds"
      ResourceIds = [each.value.id]
      RegionId    = "cn-beijing"
    }
    OOSAssumeRole = alicloud_ram_role.ram_role_oos_service.name
  })
}

# 启动服务
resource "alicloud_oos_execution" "oos_execution_start_service" {
  depends_on = [null_resource.after_30_seconds_instance]

  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

  template_name = "ACS-ECS-BulkyRunCommand"
  parameters    = jsonencode({
    regionId       = "cn-beijing"
    commandContent = <<EOT
#!/usr/bin/env bash

function install_docker() {
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo rm -rf /etc/apt/keyrings/docker.gpg
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}


function install_logtail() {
  echo ${var.name} >/etc/ilogtail/user_defined_id
}

function prepare_config() {
  mkdir -p /root/nginx/etc/nginx/conf.d/
  cat > /root/nginx/etc/nginx/conf.d/default.conf <<EOF
server {
    listen       80;
    listen  [::]:80;
    server_name  _;

    access_log  /var/log/nginx/access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
}

function start_service() {
  sudo docker run \
    -p 80:80 \
    -v /root/nginx/etc/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf \
    -v /root/nginx/var/log/nginx:/var/log/nginx \
    nginx &
}

function main() {
  install_docker
  install_logtail
  prepare_config
  start_service
}

main
EOT
    workingDir     = "/root"
    username       = "root"
    targets        = {
      Type        = "ResourceIds"
      ResourceIds = [each.value.id]
      RegionId    = "cn-beijing"
    }
    resourceType  = "ALIYUN::ECS::Instance"
    OOSAssumeRole = alicloud_ram_role.ram_role_oos_service.name
  })
}
```

## 创建 slb

```terraform
resource "alicloud_slb_load_balancer" "slb_load_balancer" {
  load_balancer_name   = "${var.name}-load-balancer"
  address_type         = "internet"
  load_balancer_spec   = "slb.s1.small"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_slb_server_group" "slb_server_group" {
  name             = "${var.name}-server-group"
  load_balancer_id = alicloud_slb_load_balancer.slb_load_balancer.id
}

resource "alicloud_slb_server_group_server_attachment" "tf-test-server-group-server-attachment" {
  count           = var.instance_number
  server_group_id = alicloud_slb_server_group.slb_server_group.id
  server_id       = alicloud_instance.instances[count.index].id
  port            = 80
}

resource "alicloud_slb_listener" "slb_listener" {
  load_balancer_id = alicloud_slb_load_balancer.slb_load_balancer.id
  backend_port     = 80
  frontend_port    = 80
  protocol         = "tcp"
  bandwidth        = 1
  server_group_id  = alicloud_slb_server_group.slb_server_group.id
}

output "slb_connection" {
  value = <<EOF
curl http://${alicloud_slb_load_balancer.slb_load_balancer.address}
EOF
}
```

## 创建 sls

```terraform
# 创建日志服务项目
resource "alicloud_log_project" "log_project" {
  name = "${var.name}-project"
}

# 创建日志服务日志库
resource "alicloud_log_store" "log_store_access_log" {
  name                  = "${var.name}-access-log"
  project               = alicloud_log_project.log_project.name
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

# 创建日志服务索引
resource "alicloud_log_store_index" "log-store-index-access-log" {
  logstore = alicloud_log_store.log_store_access_log.name
  project  = alicloud_log_project.log_project.name
  full_text {
    case_sensitive = true
    token          = "#$^*\r\n\t"
  }
  field_search {
    name             = "http_user_agent"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
  field_search {
    name             = "remote_addr"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
  field_search {
    name             = "status"
    enable_analytics = true
    type             = "long"
  }
}

# 创建日志服务机器组
resource "alicloud_log_machine_group" "log_machine_group" {
  name          = "${var.name}-machine-group"
  project       = alicloud_log_project.log_project.name
  identify_type = "userdefined"
  topic         = "${var.name}-machine-group-topic"
  identify_list = [var.name]
}

# 创建日志库配置
resource "alicloud_logtail_config" "logtail_config_access_log" {
  name         = "${var.name}-logtail-config"
  project      = alicloud_log_project.log_project.name
  logstore     = alicloud_log_store.log_store_access_log.name
  input_type   = "file"
  output_type  = "LogService"
  input_detail = <<EOF
  {
    "logPath": "/root/nginx/var/log",
    "filePattern": "access.log",
    "logType": "common_reg_log",
    "topicFormat": "default",
    "discardUnmatch": false,
    "enableRawLog": true,
    "fileEncoding": "utf8",
    "maxDepth": 10,
    "key": [
      "remote_addr", "remote_user", "time_local", "request", "version", "status", "body_bytes_sent",
      "http_referer", "http_user_agent"
    ],
    "logBeginRegex": ".*",
    "regex": "(\\S+)\\s-\\s(\\S+)\\s\\[([^]]+)]\\s\"(\\w+)([^\"]+)\"\\s(\\d+)\\s(\\d+)[^-]+([^\"]+)\"\\s\"([^\"]+).*"
 }
EOF
}

# 关联日志库配置
resource "alicloud_logtail_attachment" "logtail_attachment_access_log" {
  logtail_config_name = alicloud_logtail_config.logtail_config_access_log.name
  machine_group_name  = alicloud_log_machine_group.log_machine_group.name
  project             = alicloud_log_project.log_project.name
}

# 创建 dashboard
# 不建议使用 terraform 创建 dashboard，因为 dashboard 的配置比较复杂，不如 gui 配置简单
resource "alicloud_log_dashboard" "log_dashboard" {
  project_name   = alicloud_log_project.log_project.name
  dashboard_name = "log-dashboard"
  display_name   = "log-dashboard"
  attribute      = "{\"type\":\"grid\"}"
  char_list      = <<EOF
  [
    {
      "action": {},
      "title": "${var.name}-pv",
      "type": "linepro",
      "search": {
        "chartQueries": [
          {
            "datasource": "logstore",
            "logstore": "${alicloud_log_store.log_store_access_log.name}",
            "project": "${alicloud_log_project.log_project.name}",
            "query": "* | SELECT date_trunc('minute', __time__) AS t, COUNT(*) AS pv GROUP BY t",
            "tokenQuery": "* | SELECT date_trunc('minute', __time__) AS t, COUNT(*) AS pv GROUP BY t"
          }
        ],
        "logstore": "${alicloud_log_store.log_store_access_log.name}",
        "topic": "",
        "query": "@",
        "start": "-3600s",
        "end": "now"
      },
      "display": {
        "xAxis": [
          "time"
        ],
        "yAxis": [
          "pv"
        ],
        "xPos": 0,
        "yPos": 0,
        "width": 20,
        "height": 10,
        "displayName": "${var.name} pv"
      }
    }
  ]
EOF
}

# 创建告警
resource "alicloud_log_alert" "log_alert_status_not_200" {
  alert_displayname = "status-not-200"
  alert_name        = "status-not-200"
  project_name      = alicloud_log_project.log_project.name
  auto_annotation   = true
  mute_until        = 0
  no_data_fire      = false
  no_data_severity  = 6
  send_resolved     = false
  threshold         = 1
  type              = "default"
  version           = "2.0"

  annotations {
    key   = "title"
    value = "$${alert_name}告警触发"
  }
  annotations {
    key   = "desc"
    value = "$${alert_name}告警触发"
  }

  group_configuration {
    fields = []
    type   = "no_group"
  }

  policy_configuration {
    action_policy_id = "sls.builtin"
    alert_policy_id  = "sls.builtin.dynamic"
    repeat_interval  = "1m"
  }

  query_list {
    end            = "now"
    power_sql_mode = "disable"
    project        = alicloud_log_project.log_project.name
    query          = "status != 200 | SELECT date_trunc('minute', __time__) AS t, COUNT(*) AS pv GROUP BY t"
    region         = "cn-beijing"
    start          = "-300s"
    store          = alicloud_log_store.log_store_access_log.name
    store_type     = "log"
    time_span_type = "Relative"
  }

  schedule {
    day_of_week     = 0
    delay           = 0
    hour            = 0
    interval        = "1m"
    run_immediately = true
    type            = "FixedRate"
  }

  severity_configurations {
    eval_condition = {
      "condition"       = ""
      "count_condition" = ""
    }
    severity = 6
  }
}
```

## cms

```terraform
# 创建告警人
resource "alicloud_cms_alarm_contact" "hatlonely" {
  alarm_contact_name = "${var.name}-hatlonely"
  describe           = "${var.name} hatlonely"
  channels_mail      = "hatlonely@foxmail.com"
}

# 创建告警联系组
resource "alicloud_cms_alarm_contact_group" "cms_alarm_contact_group" {
  alarm_contact_group_name = "${var.name}-cms-alarm-contact-group"
  contacts                 = [
    alicloud_cms_alarm_contact.hatlonely.id,
  ]
}

# 创建告警监控组
resource "alicloud_cms_monitor_group" "cms_monitor_group" {
  monitor_group_name = "${var.name}-cms-monitor-group"
  contact_groups     = [
    alicloud_cms_alarm_contact_group.cms_alarm_contact_group.id,
  ]
}

# 创建告警监控组实例
resource "alicloud_cms_monitor_group_instances" "cms_monitor_group_instances" {
  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

  group_id = alicloud_cms_monitor_group.cms_monitor_group.id
  instances {
    instance_id   = each.value.id
    instance_name = each.value.instance_name
    region_id     = "cn-beijing"
    category      = "ecs"
  }
}

# 创建告警监控组规则
resource "alicloud_cms_group_metric_rule" "cms_group_metric_rule_cpu_total" {
  group_id               = alicloud_cms_monitor_group.cms_monitor_group.id
  group_metric_rule_name = "cpu-total 超过阈值"
  rule_id                = "acs_ecs_dashboard:cpu_total"
  category               = "ecs"
  metric_name            = "cpu_total"
  namespace              = "acs_ecs_dashboard"
  period                 = 60
  interval               = 3600
  silence_time           = 85800
  no_effective_interval  = "00:00-05:30"

  escalations {
    critical {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistics          = "Average"
      threshold           = 80
      times               = 3
    }

    warn {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistics          = "Average"
      threshold           = 70
      times               = 3
    }

    info {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistics          = "Average"
      threshold           = 60
      times               = 3
    }
  }
}
```

## 参考链接

- [源码地址](../code/alicloud/best-practise/1-ecs-web-service)
