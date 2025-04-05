#!/bin/bash
# 获取所有等宽字体列表（去重并排序）
font_list=$(fc-list :spacing=mono family | awk -F, '{print $1}' | sort | uniq)
# 格式化输出为 VSCode 配置所需的数组格式
echo "可用等宽字体列表："
echo "-------------------"
printf "[\n"
i=0
while IFS= read -r font; do
    [ -z "$font" ] && continue
    if [ $i -ne 0 ]; then
        printf ",\n"
    fi
    printf "  '%s'" "$font"
    ((i++))
done <<< "$font_list"
printf "\n]"