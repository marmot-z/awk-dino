#!/bin/bash

INPUT_FILE=".dino_input.tmp"
OUTPUT_FILE=".dino_output.tmp"

# 设置终端为非阻塞、无回显模式
stty -echo -icanon time 0 min 0
: > $INPUT_FILE
: > $OUTPUT_FILE

gawk -f game.awk &
AWK_PID=$!

cleanup() {
  echo -e "\n清理中..."
  kill $AWK_PID 2>/dev/null
  stty sane
  exit
}

# 捕获退出信号，恢复终端设置
trap cleanup INT TERM EXIT

printf "\n"

while true; do
  key=$(dd bs=1 count=1 2>/dev/null)

  if [[ "$key" == "q" ]]; then
    echo "检测到退出指令 'q'，退出监听。"
    break
  fi

  if [[ -n "$key" ]]; then
    echo "$key" > $INPUT_FILE
  fi

  content=$(<$OUTPUT_FILE)
  printf "\033[H"
  printf "\r$content"
  printf "\033[J"

  sleep 0.1
done
