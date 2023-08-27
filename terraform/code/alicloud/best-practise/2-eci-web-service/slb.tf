resource "alicloud_slb_load_balancer" "slb-load-balancer" {
  load_balancer_name   = "tf-test-load-balancer"
  address_type         = "internet"
  load_balancer_spec   = "slb.s1.small"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_slb_server_group" "slb-server-group" {
  name             = "tf-test-server-group"
  load_balancer_id = alicloud_slb_load_balancer.slb-load-balancer.id
}

resource "alicloud_slb_server_group_server_attachment" "tf-test-server-group-server-attachment" {
  count           = var.instance_number
  server_group_id = alicloud_slb_server_group.slb-server-group.id
  server_id       = alicloud_eci_container_group.eci-container-group[count.index].id
  port            = 80
}

resource "alicloud_slb_listener" "slb-listener" {
  load_balancer_id = alicloud_slb_load_balancer.slb-load-balancer.id
  backend_port     = 80
  frontend_port    = 80
  protocol         = "tcp"
  bandwidth        = 1
  server_group_id  = alicloud_slb_server_group.slb-server-group.id
}

output "slb_connection" {
  value = <<EOF
curl http://${alicloud_slb_load_balancer.slb-load-balancer.address}
EOF
}
