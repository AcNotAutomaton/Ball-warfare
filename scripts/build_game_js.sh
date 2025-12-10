#!/bin/bash

# 构建游戏JS文件的生产版本
JS_PATH=../game/static/js/
JS_PATH_SRC=${JS_PATH}src/
JS_PATH_DIST=${JS_PATH}dist/

# 确保dist目录存在
mkdir -p ${JS_PATH_DIST}

# 清空旧文件
> ${JS_PATH_DIST}game.js

# 按依赖顺序合并文件
echo "// 游戏基础对象类" >> ${JS_PATH_DIST}game.js
cat ${JS_PATH_SRC}playground/ac_game_object/zbase.js >> ${JS_PATH_DIST}game.js
echo "" >> ${JS_PATH_DIST}game.js

echo "// 粒子效果类" >> ${JS_PATH_DIST}game.js
cat ${JS_PATH_SRC}playground/particle/zbase.js >> ${JS_PATH_DIST}game.js
echo "" >> ${JS_PATH_DIST}game.js

echo "// 游戏地图类" >> ${JS_PATH_DIST}game.js
cat ${JS_PATH_SRC}playground/game_map/zbase.js >> ${JS_PATH_DIST}game.js
echo "" >> ${JS_PATH_DIST}game.js

echo "// 火球技能类" >> ${JS_PATH_DIST}game.js
cat ${JS_PATH_SRC}playground/skill/fireball/zbase.js >> ${JS_PATH_DIST}game.js
echo "" >> ${JS_PATH_DIST}game.js

echo "// 玩家类" >> ${JS_PATH_DIST}game.js
cat ${JS_PATH_SRC}playground/player/zbase.js >> ${JS_PATH_DIST}game.js
echo "" >> ${JS_PATH_DIST}game.js

echo "// 游戏场景类" >> ${JS_PATH_DIST}game.js
cat ${JS_PATH_SRC}playground/zbase.js >> ${JS_PATH_DIST}game.js
echo "" >> ${JS_PATH_DIST}game.js

echo "// 设置界面类" >> ${JS_PATH_DIST}game.js
if [ -f "${JS_PATH_SRC}settings/zbase.js" ]; then
    cat ${JS_PATH_SRC}settings/zbase.js >> ${JS_PATH_DIST}game.js
    echo "" >> ${JS_PATH_DIST}game.js
fi

echo "// 菜单类" >> ${JS_PATH_DIST}game.js
cat ${JS_PATH_SRC}menu/zbase.js >> ${JS_PATH_DIST}game.js
echo "" >> ${JS_PATH_DIST}game.js

echo "// 游戏主类" >> ${JS_PATH_DIST}game.js
# 保留export语句以支持模块导入
cat ${JS_PATH_SRC}zbase.js >> ${JS_PATH_DIST}game.js

echo "构建完成: ${JS_PATH_DIST}game.js"