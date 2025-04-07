# IMDb 电影搜索工具

这个Python脚本可以根据电影名称搜索IMDb数据库，并返回相关电影的详细信息。支持通过年份和导演等信息进行精确匹配。

## 功能特点

- 根据电影名称搜索IMDb数据库
- 支持通过年份、导演名称等条件进行精确筛选
- 可以限制返回结果的数量
- 提供丰富的电影详情，包括IMDb ID、标题、年份、类型、导演、评分、海报等
- 结果以JSON格式输出，方便后续处理

## 依赖安装

脚本依赖于IMDbPY/Cinemagoer库，需要先安装该依赖：

```bash
# 使用pip安装
pip install imdbpy

# 或者如果您使用pip3
pip3 install imdbpy
```

注意：IMDbPY需要Python 3.6或更高版本。

## 使用方法

### 基本用法

```bash
python imdb_search.py "电影名称"
```

### 高级用法

```bash
# 使用年份筛选
python imdb_search.py "可可西里" --year 2004

# 使用导演信息筛选
python imdb_search.py "可可西里" --director "陆川"

# 组合使用多个条件
python imdb_search.py "可可西里" --year 2004 --director "陆川"

# 限制返回结果数量（仅返回最相关的前N个结果）
python imdb_search.py "黑客帝国" --limit 1

# 精确匹配标题（避免部分匹配）
python imdb_search.py "可可西里" --exact
```

### 参数说明

- `title`：必须参数，电影名称
- `--year`：可选参数，电影发行年份
- `--director`：可选参数，导演名称
- `--exact`：可选标志，是否精确匹配标题（而非部分匹配）
- `--limit`：可选参数，限制返回结果的数量

### 添加执行权限后使用

您也可以给脚本添加执行权限后直接运行：

```bash
chmod +x imdb_search.py
./imdb_search.py "可可西里" --year 2004
```

### 输出示例

脚本会输出JSON格式的结果，例如：

```json
{
  "status": "success",
  "results": [
    {
      "imdb_id": "0331778",
      "title": "Mountain Patrol",
      "year": 2004,
      "kind": "movie",
      "plot": "在可可西里无人区，盗猎者残忍地猎杀藏羚羊。巡山队队长雷与藏族人组建了一支草原巡山队对抗盗猎者，保卫藏羚羊...",
      "directors": [
        "Lu Chuan"
      ],
      "genres": [
        "Adventure",
        "Drama"
      ],
      "rating": 7.3,
      "poster": "https://m.media-amazon.com/images/M/MV5BMTgxMjU0NjM0Nl5BMl5BanBnXkFtZTcwMDA0MzYzMQ@@._V1_UX32_CR0,0,32,44_AL_.jpg",
      "poster_full": "https://m.media-amazon.com/images/M/MV5BMTgxMjU0NjM0Nl5BMl5BanBnXkFtZTcwMDA0MzYzMQ@@._V1_SX300.jpg",
      "cast": [
        {
          "name": "Duobuji",
          "role": "Ritai"
        },
        {
          "name": "Zhang Lei",
          "role": "Ga Yu"
        },
        {
          "name": "Qi Liang",
          "role": "Liu Dong"
        },
        {
          "name": "Zhao Xueying",
          "role": "Leng Xue"
        },
        {
          "name": "Ma Zhanlin",
          "role": "A Guo"
        }
      ]
    }
  ],
  "count": 1
}
```

## 错误处理

如果搜索过程中出现错误，或者没有找到匹配的电影，脚本会返回错误信息：

```json
{
  "status": "error",
  "message": "未找到符合条件的电影：标题='可可西里'，年份=2005，导演=陆川"
}
```

## 注意事项

1. 搜索结果默认按照相关度排序，最相关的结果排在前面
2. 演员列表默认限制为前5名，避免结果过于冗长
3. 海报URL提供两种尺寸：普通尺寸和全尺寸
4. 通过年份和导演过滤可能会减慢搜索速度，因为需要获取每个电影的详细信息
5. 导演名称匹配不区分大小写，但需要注意中英文名称可能不同
6. 脚本依赖于IMDb的数据可用性，某些电影可能缺少特定信息

## 自定义修改

如果需要修改脚本功能，可以考虑：

- 调整演员列表的数量限制
- 增加更多信息字段
- 修改输出格式
- 添加更多排序和过滤选项

## 故障排除

- 如果遇到网络问题，可能会导致搜索失败，请检查网络连接
- IMDbPY可能偶尔会因为IMDb网站的变化而需要更新，请确保使用最新版本
- 如果搜索中文电影名效果不佳，可以尝试使用英文名称或原始名称
- 使用`--director`参数时，注意导演的名字可能需要使用IMDb上的拼写方式（如"Lu Chuan"而非"陆川"）
