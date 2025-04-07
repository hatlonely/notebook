#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
根据电影名称搜索IMDb信息的脚本

使用方法:
    python imdb_search.py "电影名称" [--year 年份] [--director 导演名] [--exact] [--limit 数量]
"""

import sys
import json
import argparse
from imdb import Cinemagoer

def convert_to_serializable(obj):
    """
    将对象转换为可JSON序列化的格式
    
    Args:
        obj: 需要转换的对象
        
    Returns:
        可序列化的对象
    """
    if hasattr(obj, '__dict__'):
        return str(obj)
    elif isinstance(obj, (list, tuple)):
        return [convert_to_serializable(item) for item in obj]
    elif isinstance(obj, dict):
        return {k: convert_to_serializable(v) for k, v in obj.items()}
    else:
        return obj

def filter_by_criteria(movies, year=None, director=None, exact=False):
    """
    根据年份和导演信息过滤电影
    
    Args:
        movies: 电影列表
        year: 电影年份
        director: 导演名称
        exact: 是否精确匹配标题
        
    Returns:
        过滤后的电影列表
    """
    ia = Cinemagoer()
    filtered_movies = []
    
    for movie in movies:
        # 如果要求精确匹配，检查标题是否完全一致
        if exact and movie.get('title').lower() != query.lower():
            continue
            
        # 如果指定了年份，检查是否匹配
        if year and movie.get('year') != year:
            continue
            
        # 导演信息通常不在搜索结果中，需要获取详细信息
        if director:
            try:
                # 如果电影还没有详细信息，获取它
                if 'director' not in movie:
                    ia.update(movie)
                
                # 检查导演是否匹配
                if 'director' in movie:
                    director_names = [d.get('name', '').lower() for d in movie.get('director', [])]
                    if director.lower() not in director_names:
                        continue
                else:
                    # 如果无法获取导演信息，跳过这部电影
                    continue
            except Exception:
                # 如果出错，跳过这部电影
                continue
                
        # 通过所有过滤条件，添加到结果中
        filtered_movies.append(movie)
        
    return filtered_movies

def search_movie(movie_name, year=None, director=None, exact=False, limit=None):
    """
    根据电影名称搜索IMDb信息
    
    Args:
        movie_name: 电影名称
        year: 电影年份（可选）
        director: 导演名称（可选）
        exact: 是否精确匹配标题
        limit: 限制返回结果数量
        
    Returns:
        搜索结果列表
    """
    # 创建Cinemagoer实例
    ia = Cinemagoer()
    
    try:
        # 搜索电影
        search_results = ia.search_movie(movie_name)
        
        if not search_results:
            return {"status": "error", "message": f"未找到与 '{movie_name}' 相关的电影信息"}
            
        # 如果需要过滤，应用过滤条件
        if year or director or exact:
            filtered_results = filter_by_criteria(search_results, year, director, exact)
            if not filtered_results:
                return {"status": "error", "message": f"未找到符合条件的电影：标题='{movie_name}'，年份={year}，导演={director}"}
            search_results = filtered_results
            
        # 如果设置了结果数量限制
        if limit and limit > 0:
            search_results = search_results[:limit]
        
        # 处理搜索结果
        results = []
        
        for movie in search_results:
            # 获取基本信息
            movie_data = {
                "imdb_id": movie.getID(),
                "title": movie.get('title', ''),
                "year": movie.get('year', ''),
                "kind": movie.get('kind', ''),  # movie, tv series, etc.
            }
            
            # 获取更多详细信息
            try:
                ia.update(movie)
                
                # 添加详细信息（如果有）
                if 'plot' in movie:
                    plots = movie.get('plot', [])
                    movie_data["plot"] = plots[0] if plots else ''
                
                if 'director' in movie:
                    directors = [d.get('name', '') for d in movie.get('director', [])]
                    movie_data["directors"] = directors
                
                if 'genres' in movie:
                    movie_data["genres"] = movie.get('genres', [])
                
                if 'rating' in movie:
                    movie_data["rating"] = movie.get('rating', '')
                
                if 'cover url' in movie:
                    movie_data["poster"] = movie.get('cover url', '')
                
                if 'full-size cover url' in movie:
                    movie_data["poster_full"] = movie.get('full-size cover url', '')
                
                if 'cast' in movie:
                    cast = []
                    for actor in movie.get('cast', [])[:5]:  # 限制演员列表长度
                        actor_data = {"name": actor.get('name', '')}
                        
                        # 正确处理角色信息，避免序列化问题
                        if hasattr(actor, 'currentRole'):
                            if hasattr(actor.currentRole, 'data') and 'name' in actor.currentRole.data:
                                actor_data["role"] = actor.currentRole.data['name']
                            else:
                                actor_data["role"] = str(actor.currentRole)
                        else:
                            actor_data["role"] = ""
                            
                        cast.append(actor_data)
                    movie_data["cast"] = cast
            except Exception as e:
                movie_data["update_error"] = str(e)
            
            results.append(movie_data)
        
        return {"status": "success", "results": results, "count": len(results)}
    
    except Exception as e:
        return {"status": "error", "message": f"搜索出错: {str(e)}"}

def main():
    """主函数"""
    # 创建参数解析器
    parser = argparse.ArgumentParser(description='根据电影名称搜索IMDb信息')
    parser.add_argument('title', type=str, help='电影名称')
    parser.add_argument('--year', type=int, help='电影年份')
    parser.add_argument('--director', type=str, help='导演名称')
    parser.add_argument('--exact', action='store_true', help='精确匹配标题')
    parser.add_argument('--limit', type=int, help='限制返回结果数量')
    
    # 解析参数
    args = parser.parse_args()
    
    # 搜索电影
    result = search_movie(args.title, args.year, args.director, args.exact, args.limit)
    
    # 转换为格式化的JSON字符串输出
    print(json.dumps(result, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
