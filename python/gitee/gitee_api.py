import json

import requests
import yaml


def json_object(cls):
    def _init_from_dict__(self, d: dict):
        for field, field_type in cls.__annotations__.items():
            # 跳过不存在的字段
            if field not in d:
                setattr(self, field, None)
                continue
            if d.get(field) is None:
                setattr(self, field, None)
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


@json_object
class Webhook:
    id: int
    url: str
    created_at: str
    password: str
    project_id: int
    result: str
    result_code: int
    push_events: bool
    tag_push_events: bool
    issues_events: bool
    note_events: bool
    merge_requests_events: bool


@json_object
class CreateWebhookReq:
    owner: str
    repo: str
    url: str
    encryption_type: int
    password: str
    push_events: bool
    tag_push_events: bool
    issues_events: bool
    note_events: bool
    merge_requests_events: bool


CreateWebhookRes = Webhook


@json_object
class ListWebhookReq:
    owner: str
    repo: str
    page: int
    per_page: int


ListWebhookRes = list[Webhook]


class Gitee:
    def __init__(self, access_token):
        self.access_token = access_token

    def list_webhook(self, req: ListWebhookReq) -> ListWebhookRes:
        url = f"https://gitee.com/api/v5/repos/{req.owner}/{req.repo}/hooks"
        headers = {'Content-Type': 'application/json;charset=UTF-8'}
        params = {
            "access_token": self.access_token,
            "page": req.page if req.page else 1,
            "per_page": req.per_page if req.per_page else 20,
        }

        response = requests.get(url, headers=headers, params=params)
        res = ListWebhookRes()
        for e in response.json():
            res.append(Webhook(e))
        return res

    def create_webhook(self, req: CreateWebhookReq) -> CreateWebhookRes:
        id_ = None
        for webhook in self.list_webhook(ListWebhookReq.create(
            owner=req.owner,
            repo=req.repo,
        )):
            if webhook.url == req.url:
                id_ = webhook.id

        url = f"https://gitee.com/api/v5/repos/{req.owner}/{req.repo}/hooks"
        headers = {'Content-Type': 'application/json;charset=UTF-8'}
        data = {
            "access_token": self.access_token,
            "url": req.url,
            "encryption_type": req.encryption_type,
            "password": req.password,
            "push_events": req.push_events,
            "tag_push_events": req.tag_push_events,
            "issues_events": req.issues_events,
            "note_events": req.note_events,
            "merge_requests_events": req.merge_requests_events,
        }

        if id_:  # update
            url = f"https://gitee.com/api/v5/repos/{req.owner}/{req.repo}/hooks/{id_}"
            response = requests.patch(
                url, headers=headers, data=json.dumps(data))
            return CreateWebhookRes(response.json())
        response = requests.post(url, headers=headers, data=json.dumps(data))
        return CreateWebhookRes(response.json())


def main():
    gitee = Gitee("test-token")
    res = gitee.create_webhook(CreateWebhookReq.create(
        owner="hatlonely",
        repo="dockerhub",
        url="https://jenkins.hatlonely.com:18443/gitee-project/dockerhub",
        encryption_type=0,
        password="123456",
        push_events=True,
        tag_push_events=False,
        issues_events=False,
        note_events=False,
        merge_requests_events=True,
    ))

    print(res)


if __name__ == "__main__":
    main()
