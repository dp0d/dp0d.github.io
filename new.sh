#!/bin/bash

# real path
base_path="content/posts/2023/"

# 获取命令行参数（文件名）
filename=$1

# 检查文件名是否为空
if [ -z "$filename" ]; then
  echo "请提供要创建的文件名"
  exit 1
fi

# 创建文件的短路径，和真实路径相差一个content
file_path="posts/2023/$filename/index.md"

# 检查目标路径是否存在
if [ ! -d "$base_path" ]; then
  echo "目标路径不存在：$base_path"
  exit 1
fi

# 检查文件是否已存在
if [ -e "$base_path$filename" ]; then
  echo "文件已存在：$base_path$filename"
else
  # 在指定路径下创建文件
  hugo new $file_path
fi
