#!/bin/bash

# 获取所有等宽字体并格式化输出
font_list=$(fc-list :spacing=mono family | 
    awk -F, '{
        gsub(/[:].*/, "", $1)  # 移除冒号后的样式描述
        gsub(/[ ]*$/, "", $1)  # 去除行尾空格
        print "\047" $1 "\047" # 添加单引号包裹
    }' | 
    sort -u |
    tr '\n' ',' | 
    sed 's/,$//')  # 转换为逗号分隔的字符串

# 添加最后的monospace回退
echo "${font_list}, monospace"