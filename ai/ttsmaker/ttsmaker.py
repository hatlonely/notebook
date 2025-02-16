#!/usr/bin/env python3

import json
import os

import requests

api_key = os.getenv('TTS_MAKER_API_KEY')

# https://pro.ttsmaker.com/api-platform/zh-cn/api-docs-v2
#
# POST https://api.ttsmaker.com/v2/create-tts-order
# Header: Content-Type: application/json
# Body:
# {
#   "api_key": "replace_this_demo_key",
#   "text": "Please fill in the text that needs to be converted to speech.",
#   "voice_id": 1480,
#   "audio_format": "mp3",
#   "audio_speed": 1,
#   "audio_volume": 0,
#   "audio_pitch": 1,
#   "audio_high_quality": 0,
#   "text_paragraph_pause_time": 0,
#   "emotion_style_key": "",
#   "emotion_intensity": 1
# }


def make_tts(content):
    url = 'https://api.ttsmaker.com/v2/create-tts-order'
    headers = {
        'Content-Type': 'application/json'
    }
    data = {
        'api_key': api_key,
        'text': content,
        'voice_id': 1522,
        'audio_format': 'wav',
        'audio_speed': 1,
        'audio_volume': 1,
        'audio_pitch': 1,
        'audio_high_quality': 1,
    }
    response = requests.post(url, headers=headers, data=json.dumps(data))
    response.raise_for_status()
    return response.json()


content = """测试"""

res = make_tts(content)
print(json.dumps(res))
