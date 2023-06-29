from dataclasses import dataclass

import oss2
import yaml
from alibabacloud_imm20200930.client import Client as imm20200930Client
from alibabacloud_tea_openapi import models as open_api_models


@dataclass
class Options:
    @dataclass
    class OSSOptions:
        endpoint: str
        bucket: str
        access_key_id: str
        access_key_secret: str

    @dataclass
    class IMMOptions:
        endpoint: str
        access_key_id: str
        access_key_secret: str

    oss: OSSOptions
    imm: IMMOptions

    def __init__(self, **kwargs):
        self.oss = self.OSSOptions(**kwargs["oss"])
        self.imm = self.IMMOptions(**kwargs["imm"])


class Environment:
    options: Options
    oss_bucket: oss2.Bucket
    imm_client: imm20200930Client

    def __init__(self, config):
        with open(config, "r") as config:
            cfg = yaml.safe_load(config)
            self.options = Options(**cfg)

        # oss client
        auth = oss2.Auth(self.options.oss.access_key_id, self.options.oss.access_key_secret)
        self.oss_bucket = oss2.Bucket(auth, self.options.oss.endpoint, self.options.oss.bucket)

        # imm client
        self.imm_client = imm20200930Client(open_api_models.Config(
            access_key_id=self.options.imm.access_key_id,
            access_key_secret=self.options.imm.access_key_secret,
            endpoint=self.options.imm.endpoint,
        ))
