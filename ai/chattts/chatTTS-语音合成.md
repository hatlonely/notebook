# ChatTTS 语音合成

```sh
# 制作镜像
docker build . -t chattts

# 运行
docker run -ti --rm -p 8080:8080 --gpus all chattts
```
