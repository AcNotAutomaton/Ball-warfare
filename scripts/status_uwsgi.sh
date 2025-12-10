#!/bin/bash

# uWSGI 状态检查脚本
# 使用方法: ./status_uwsgi.sh

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INI_FILE="$SCRIPT_DIR/uwsgi.ini"
LOG_DIR="$PROJECT_DIR/logs"

echo "uWSGI 状态检查"
echo "=================="
echo ""

# 检查配置文件
echo "配置文件: $INI_FILE"
if [ -f "$INI_FILE" ]; then
    echo "✓ 配置文件存在"
else
    echo "✗ 配置文件不存在"
fi
echo ""

# 检查进程
echo "运行状态:"
UWSGI_PIDS=$(pgrep -f "uwsgi.*$INI_FILE" 2>/dev/null)
if [ -z "$UWSGI_PIDS" ]; then
    # 尝试查找所有 uwsgi 进程
    UWSGI_PIDS=$(pgrep uwsgi 2>/dev/null)
fi

if [ ! -z "$UWSGI_PIDS" ]; then
    echo "✓ uWSGI 正在运行"
    echo "进程信息:"
    ps -p $UWSGI_PIDS -o pid,ppid,etime,pcpu,pmem,cmd 2>/dev/null | while read line; do
        echo "  $line"
    done
else
    echo "✗ uWSGI 未运行"
fi
echo ""

# 检查端口占用
echo "端口监听状态:"
if command -v netstat &> /dev/null; then
    echo "HTTP端口 9001:"
    if netstat -tlnp 2>/dev/null | grep -q ":9001 "; then
        netstat -tlnp 2>/dev/null | grep ":9001 " | while read line; do
            echo "  ✓ $line"
        done
    else
        echo "  ✗ 端口 9001 未监听"
    fi

    echo "Socket端口 8000:"
    if netstat -tlnp 2>/dev/null | grep -q ":8000 "; then
        netstat -tlnp 2>/dev/null | grep ":8000 " | while read line; do
            echo "  ✓ $line"
        done
    else
        echo "  ✗ 端口 8000 未监听"
    fi
elif command -v ss &> /dev/null; then
    echo "HTTP端口 9001:"
    if ss -tlnp 2>/dev/null | grep -q ":9001 "; then
        ss -tlnp 2>/dev/null | grep ":9001 " | while read line; do
            echo "  ✓ $line"
        done
    else
        echo "  ✗ 端口 9001 未监听"
    fi

    echo "Socket端口 8000:"
    if ss -tlnp 2>/dev/null | grep -q ":8000 "; then
        ss -tlnp 2>/dev/null | grep ":8000 " | while read line; do
            echo "  ✓ $line"
        done
    else
        echo "  ✗ 端口 8000 未监听"
    fi
fi
echo ""

# 检查日志
echo "日志文件:"
if [ -f "$LOG_DIR/uwsgi.log" ]; then
    echo "✓ 日志文件存在: $LOG_DIR/uwsgi.log"
    echo "最后5行日志:"
    tail -n 5 "$LOG_DIR/uwsgi.log" | while read line; do
        echo "  $line"
    done
else
    echo "✗ 日志文件不存在: $LOG_DIR/uwsgi.log"
fi