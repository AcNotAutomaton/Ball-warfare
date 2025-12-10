#!/bin/bash

# uWSGI 停止脚本
# 使用方法: ./stop_uwsgi.sh

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INI_FILE="$SCRIPT_DIR/uwsgi.ini"

# 查找 uwsgi 进程
echo "正在查找 uWSGI 进程..."

# 查找所有匹配的 uwsgi 进程
UWSGI_PIDS=$(pgrep -f "uwsgi.*$INI_FILE" 2>/dev/null)

if [ -z "$UWSGI_PIDS" ]; then
    # 尝试查找所有 uwsgi 进程
    UWSGI_PIDS=$(pgrep uwsgi 2>/dev/null)
fi

if [ -z "$UWSGI_PIDS" ]; then
    echo "✓ 没有找到运行中的 uWSGI 进程"
    exit 0
fi

echo "找到以下 uWSGI 进程:"
ps -p $UWSGI_PIDS -o pid,ppid,cmd 2>/dev/null

# 尝试优雅关闭
echo ""
echo "尝试优雅关闭 uWSGI 进程..."

for PID in $UWSGI_PIDS; do
    if kill -TERM "$PID" 2>/dev/null; then
        echo "→ 向进程 $PID 发送 SIGTERM 信号"
    fi
done

# 等待进程关闭
echo "等待进程关闭..."
sleep 3

# 检查是否还有进程在运行
REMAINING_PIDS=$(pgrep -f "uwsgi.*$INI_FILE" 2>/dev/null)
if [ -z "$REMAINING_PIDS" ]; then
    REMAINING_PIDS=$(pgrep uwsgi 2>/dev/null)
fi

if [ ! -z "$REMAINING_PIDS" ]; then
    echo ""
    echo "警告: 仍有进程在运行，强制终止..."
    for PID in $REMAINING_PIDS; do
        if kill -KILL "$PID" 2>/dev/null; then
            echo "→ 强制终止进程 $PID"
        fi
    done
    sleep 1
fi

# 最终检查
FINAL_PIDS=$(pgrep -f "uwsgi.*$INI_FILE" 2>/dev/null)
if [ -z "$FINAL_PIDS" ]; then
    FINAL_PIDS=$(pgrep uwsgi 2>/dev/null)
fi

if [ -z "$FINAL_PIDS" ]; then
    echo ""
    echo "✓ 所有 uWSGI 进程已成功关闭"
else
    echo ""
    echo "✗ 仍有进程未能关闭:"
    ps -p $FINAL_PIDS -o pid,ppid,cmd 2>/dev/null
    exit 1
fi