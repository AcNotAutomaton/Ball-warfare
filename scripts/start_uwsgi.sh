#!/bin/bash

# uWSGI 启动脚本
# 使用方法: ./start_uwsgi.sh

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 检查虚拟环境
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    echo "错误: 虚拟环境不存在: $PROJECT_DIR/.venv"
    exit 1
fi

# 激活虚拟环境
source "$PROJECT_DIR/.venv/bin/activate"

# 检查 uwsgi 是否已安装
if ! command -v uwsgi &> /dev/null; then
    echo "错误: uwsgi 未安装，请先安装: pip install uwsgi"
    exit 1
fi

# 检查配置文件
INI_FILE="$SCRIPT_DIR/uwsgi.ini"
if [ ! -f "$INI_FILE" ]; then
    echo "错误: 配置文件不存在: $INI_FILE"
    exit 1
fi

# 检查是否已有 uwsgi 进程运行
if pgrep -f "uwsgi.*$INI_FILE" > /dev/null; then
    echo "警告: uwsgi 已在运行，先关闭现有进程..."
    "$SCRIPT_DIR/stop_uwsgi.sh"
    sleep 2
fi

# 创建日志目录
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

# 启动 uwsgi
echo "启动 uWSGI..."
echo "项目目录: $PROJECT_DIR"
echo "配置文件: $INI_FILE"
echo "日志文件: $LOG_DIR/uwsgi.log"

# 使用 nohup 在后台启动，并将日志输出到文件
nohup uwsgi --ini "$INI_FILE" > "$LOG_DIR/uwsgi.log" 2>&1 &

# 等待一下让进程启动
sleep 3

# 检查是否启动成功
if pgrep -f "uwsgi.*$INI_FILE" > /dev/null; then
    echo "✓ uWSGI 启动成功!"
    echo "进程ID: $(pgrep -f 'uwsgi.*'$INI_FILE | tr '\n' ' ')"
    echo "HTTP 访问地址: http://localhost:9001"
    echo "Socket 地址: localhost:8000"
    echo "日志文件: $LOG_DIR/uwsgi.log"
else
    echo "✗ uWSGI 启动失败!"
    echo "请检查日志文件: $LOG_DIR/uwsgi.log"
    exit 1
fi