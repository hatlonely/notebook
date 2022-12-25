# ROS 模板语法

## 模板结构

```yaml
ROSTemplateFormatVersion: '2015-09-01' # 模板版本信息
Description: ros quick start           # 描述信息
Parameters:                            # 模板参数
  VpcCidrBlock:
    Type: String
    Default: 192.168.0.0/16
Metadata: {}    # 元数据信息，例如存放用于可视化的布局信息
Mappings: {}    # 映射信息，自定义数据
Conditions: {}  # 使用内部条件函数定义条件，这些条件确定何时创建关联的资源
Outputs: {}     # 用于输出一些资源属性等有用信息，可以通过API或控制台获取输出的内容
Resources:      # 资源信息
  VPC:          # 资源名称，后面通过该名称引用该资源
    Type: ALIYUN::ECS::VPC
    Properties:
      VpcName: myvpc
      CidrBlock:
        Ref: VpcCidrBlock
```

## Resources

用于描述具体的阿里云资源，比如 vpc/ecs/rds/oss 等

这是一个创建 vpc 资源的示例

```yaml
Type: ALIYUN::ECS::VPC
Properties:
  VpcName: myvpc
  CidrBlock:
    Ref: VpcCidrBlock
```

其语法结构如下:

- `Type`: [资源类型](https://help.aliyun.com/document_detail/127039.html)
- `Properties`: 资源属性，不同的 `Type` 有不同的属性
- `DeletionPolicy`: 删除策略，设置为 `Retain` 时，当资源栈删除时，该资源会被保留
- `DependsOn`: 显式依赖，当 `DependsOn` 资源创建成功之后，该资源才会创建
- `Condition`: 创建条件，只有当条件为 `True` 时，该资源才会创建
- `Count`: 创建资源的副本数，后面通过数组下标语法引用资源

## Parameters

模板参数，这些参数在资源创建的时候通过 API 或者控制台传入，可以在后面的资源中引用。

这个是一个参数的示例

```yaml
Parameters:
  VpcCidrBlock:
    Type: String
    Default: 192.168.0.0/16
```

其语法结构如下：

- `Type`: 参数类型，可选值 `String/Number/Json/Boolean`，其他值包括
    - `CommaDelimitedList`: 逗号分隔的列表，例如 `"80, foo, bar"`，后续可以通过 `Fn::Select` 函数索引值
    - `ALIYUN::OOS::Parameter::Value`: 存储在OOS参数仓库中的普通参数，例如：my_image
    - `ALIYUN::OOS::SecretParameter::Value`: 存储在OOS参数仓库中的加密参数，例如：my_password
- `Default`: 默认值
- `AllowedValues`: 可选值
- `AllowedPattern`: 输入值必须满足正则表达式
- `MaxLength`: 字符串最大长度
- `MinLength`: 字符串最短长度
- `MaxValue`: 数值最大值
- `MinValue`: 数值最小值
- `NoEcho`: 敏感信息，设置为 true 时，查询时不会输出值，只会输出 `*`
- `Description`: 参数描述信息
- `ConstraintDescription`: 参数不合法时的描述信息
- `Label`: 参数别名，支持 utf8 字符
- `AssociationProperty`: [预定义的参数合法性检查](https://help.aliyun.com/document_detail/315578.htm)
- `AssociationPropertyMetadata`: 和 `AssociationProperty` 配合使用，用于筛选符合条件的结果
- `Confirm`: 当参数为 NoEcho 时，参数需要二次输入确认。
- `TextArea`: 是否支持换行

## Outputs

Outputs 定义在调用查询资源栈接口时返回的值

这是一个输出 WebServer.InstanceId 的示例

```yaml
Outputs:
  InstanceId:
    Value:
      "Fn::GetAtt":
        - "WebServer"
        - "InstanceId"
```

其语法结构如下:

- `Value`: 输出值，一般通过 `Fn::GetAtt` 方法获取资源的属性
- `Description`: 输出值描述
- `Condition`: 满足条件才输出
- `Label`: 输出别名

## Mappings

映射是一个Key-Value映射表。在模板的Resources和Outputs中，可以使用Fn::FindInMap内部函数，通过指定Key而获取映射表的Value。

## Conditions

创建全局的条件，这些条件可以在后面的资源中直接引用

## 伪参数（Pseudo parameters）

伪参数相当于预定义参数，这些参数不需要定义，内置在模板中

- `ALIYUN::StackName`: 资源栈名称
- `ALIYUN::StackId`:资源栈ID
- `ALIYUN::Region`: 资源栈所在地域
- `ALIYUN::AccountId`:执行者账号ID
- `ALIYUN::TenantId`: 当前账号的阿里云账号ID
- `ALIYUN::NoValue`: 创建或更新资源栈时，如果ALIYUN::NoValue用于可选属性，则将删除该属性；如果ALIYUN::NoValue用于必选属性，则将按类型获取默认值（例如，用于String类型的属性值为空字符串；用于Integer类型的属性值为0；用于数组类型属性值为空数组等）
- `ALIYUN::Index`: 一个特殊的伪参数，仅在资源 Count 功能中使用，其他情况不能使用

## Metadata

模板的元数据信息

其语法结构如下:

- `ALIYUN::ROS::Interface`: 模板元数据信息
    - `ParameterGroups`: 参数组，将多个参数合并成一个组，这些参数在创建模板时会显示在一起
    - `TemplateTags`: 模板的标签

## Rules

规则（Rules）用于检验在创建或更新资源栈时传递给模板的参数值是否符合预期

## 函数

YAML 的描述性语言特性，无法完整表达资源创建过程中的逻辑关系，ROS 提供丰富的函数来补充这部分能力

- `Fn::Str`: 数值转字符串
- `Fn::Base64Encode`: base64 编码
- `Fn::Base64Decode`: base64 解码
- `Fn::FindInMap`: 从 Mapping 声明的双重映射中获取值，比如 `{"Fn::FindInMap": ["MapName", "TopLevelKey", "SecondLevelKey"]}`
- `Fn::GetAtt`: 从对象中获取属性，比如获取 ecs 的 InstanceId `{"Fn::GetAtt": ["MyEcsInstance" , "InstanceId"]}`
- `Fn::Join`: 字符串拼接
- `Fn::Sub`: 格式化输出，和 python 中的 format 方法类似

```json
"Fn::Sub": [
    "Var1: ${Var1}, Var2: ${Var2}, StackName: ${ALIYUN::StackName}, Region: ${ALIYUN::Region}",
    {
      "Var1": "Var1Value",
      "Var2": "Var2Value"
    }
]
```

- `Fn::Select`: 通过索引返回数组或者字典中的值

```js
{"Fn::Select": ["index", ["value1", "value2", ...]]}
{"Fn::Select": ["start:stop", ["value1", "value2", ...]]}
{"Fn::Select": ["start:stop:step", ["value1", "value2", ... ]]}
{"Fn::Select": ["key", {"key1": "value1", "key2": "value2", ...}]}
```  

- `Ref`: 引用参数或者资源的值
- `Fn::GetAZs`: 获取当前地区的可用区列表
- `Fn::Replace`: 字符串替换
- `Fn::Split`: 字符串切片，`{"Fn::Split": [";", "foo; bar; achoo"]}`
- `Fn::Equals`: 比较两个值是否相等
- `Fn::And`: 条件与
- `Fn::Or`: 条件或
- `Fn::Not`: 条件否
- `Fn::Index`: 列表查找下标
- `Fn::If`: 条件选择 `{"Fn::If": ["condition_name", "value_if_true", "value_if_false"]}`
- `Fn::Length`: 对象长度，可以是字符串，列表，字典
- `Fn::ListMerge`: 列表合并，`{"Fn::ListMerge": [["list_1_item_1", "list_1_imte_2", ...], ["list_2_item_1", "list_2_imte_2", ...]]}`
- `Fn::GetJsonValue`: 解析 json 字符串，获取 key 对应的值
- `Fn::MergeMapToList`: 字典数组转成另一种形式
- `Fn::Avg`: 求平均值 `{"Fn::Avg": [ndigits, [number1, number2, ...]]}`
- `Fn::SelectMapList`: 内部函数Fn::SelectMapList返回一个由map中元素构成的列表
- `Fn::Add`: 求和
- `Fn::Calculate`: 表达式计算

```js
{"Fn::Calculate": ["(2+3)/2*3-1", 1]}  
{"Fn::Calculate": ["(2.0+3)/2*3-1", 1]}
{"Fn::Calculate": ["({1}+3)/2*3-1", 1, [3, 5, 6]]}
{"Fn::Calculate": ["({0}+{1})%3", 0, [5, 6]]}
```

- `Fn::Max`: 最大值
- `Fn::Min`: 最小值
- `Fn::GetStackOutput`: 获取资源栈输出
- `Fn::Jq`: [jq](https://stedolan.github.io/jq/manual/) 过滤器
- `Fn::FormatTime`: 格式化当前时间 `{"Fn::FormatTime": ["%Y-%m-%d %H:%M:%S","Asia/Shanghai"]}`
- `Fn::MarketplaceImage`: 云市场镜像商品Code的默认镜像ID
- `Fn::Any`: 任意为真时返回真
- `Fn::Contains`: 列表包含
- `Fn::EachMemberIn`: 列表1中的每个成员都在列表2中
- `Fn::MatchPattern`: 符合正则表达式

## 参考链接

- ROS 模板语法: <https://help.aliyun.com/document_detail/28858.html>
