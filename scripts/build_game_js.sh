#!/bin/bash

# 将游戏中所有JS源码合并为dist/game.js。
# 关键顺序依赖命名: menu -> playground/* -> settings -> zbase，
# 新增js文件放入src后会自动被包含，无需再改本脚本。

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

JS_PATH="$PROJECT_DIR/game/static/js/"
JS_PATH_SRC="${JS_PATH}src/"
JS_PATH_DIST="${JS_PATH}dist/"

mkdir -p "$JS_PATH_DIST"

FILES=$(find "$JS_PATH_SRC" -type f -name '*.js' | sort)

if command -v terser &> /dev/null; then
    echo "$FILES" | xargs cat | terser -c -m > "${JS_PATH_DIST}game.js"
else
    echo "$FILES" | xargs cat > "${JS_PATH_DIST}game.js"
fi

echo "构建完成: ${JS_PATH_DIST}game.js"

# 同步Django的静态目录
cd "$PROJECT_DIR" && .venv/bin/python manage.py collectstatic --noinput
