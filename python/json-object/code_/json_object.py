import json

import yaml


def json_object(cls):
    def _init_from_dict__(self, d: dict):
        for field, field_type in cls.__annotations__.items():
            # 跳过不存在的字段
            if field not in d or not d.get(field):
                continue
            # 列表类型
            if (
                hasattr(field_type, "__class_getitem__")
                and field_type.__origin__ is list
                and field_type.__args__
            ):
                eles = field_type()
                for e in d.get(field, []):
                    eles.append(field_type.__args__[0](e))
                setattr(self, field, eles)
            # 字典类型
            elif hasattr(field_type, "__origin__") and field_type.__origin__ is dict:
                val = field_type()
                for k, v in d.get(field, {}).items():
                    val.update({k: field_type.__args__[1](v)})
                setattr(self, field, val)
            else:
                val = d.get(field)
                val = json.loads(json.dumps(val, default=lambda x: vars(x)))
                setattr(self, field, field_type(val))

    def _init__(self, s=None, type_="json"):
        if not s:
            return

        t = type(s)
        if t is str or t is bytes:
            if type_ == "json":
                s = json.loads(s)
            if type_ == "yaml":
                s = yaml.safe_load(s)
        if t is not dict:
            s = json.loads(json.dumps(s, default=lambda x: vars(x)))
        _init_from_dict__(self, s)

    def _str__(self):
        return json.dumps(vars(self), default=lambda x: vars(x), indent=2)

    def create(**kwargs):
        obj = cls()
        _init_from_dict__(obj, kwargs)
        return obj

    setattr(cls, "__init__", _init__)
    setattr(cls, "__str__", _str__)
    setattr(cls, "create", create)

    return cls
