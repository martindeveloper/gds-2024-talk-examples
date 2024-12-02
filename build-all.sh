#!/bin/sh
set -e

SCRIPT_ROOT=$(dirname "$(realpath "$0")")
ZIG_PATH=""
ZIG_VERSION=""
ODIN_PATH=""
ODIN_VERSION=""

echo "GDS 2024 Sample Code Repository"
echo ""

echo "[Zig] Building"

if ! command -v zig &> /dev/null; then
    echo "[FATAL] zig is not installed!"
    exit 1
else
   ZIG_VERSION=$(zig version)
   ZIG_PATH=$(which zig)
fi

echo "[Zig] Path: $ZIG_PATH"
echo "[Zig] Version: $ZIG_VERSION"

find "$SCRIPT_ROOT/src/zig" -type d | while read -r PROJECT; do
    if [ -f "$PROJECT/build.zig" ]; then
        echo " - Building at '$PROJECT'"
        cd "$PROJECT"
        
        if ! zig build -freference-trace; then
            echo "[ERROR] Error building project: $PROJECT"
            cd - > /dev/null
            continue
        fi
        
        cd - > /dev/null
    fi
done

echo "[Zig] Done"
echo ""

echo "[Odin] Building"

if ! command -v odin &> /dev/null; then
    echo "[FATAL] odin is not installed!"
    exit 1
else
    ODIN_VERSION=$(odin version)
    ODIN_PATH=$(which odin)
fi

echo "[Odin] Path: $ODIN_PATH"
echo "[Odin] Version: $ODIN_VERSION"

find "$SCRIPT_ROOT/src/odin" -type d | while read -r PROJECT; do
    if [ -f "$PROJECT/main.odin" ]; then
        echo " - Building at '$PROJECT'"
        cd "$PROJECT"
        FOLDER_BASE_NAME=$(basename $PROJECT)
        OUT_FOLDER="$PROJECT/odin-out"
        OUT_FILEPATH="$OUT_FOLDER/$FOLDER_BASE_NAME"

        echo " - mkdir if not exists: $OUT_FOLDER"
        mkdir -p "$OUT_FOLDER"

        if ! odin build . -build-mode:exe -out:"$OUT_FILEPATH" -debug; then
            echo "[ERROR] Error building project: $PROJECT"
            cd - > /dev/null
            continue
        fi
        
        cd - > /dev/null
    fi
done

echo "[Odin] Done"

exit 0
