# 读取缓存文件中的事件
# 更新视图
# 障碍物的生成（数组的更新）
# 玩家的移动（位置的更新）
# 重力
# 前进速度
# 视图的渲染（恐龙、树、蝙蝠）
# 判断元素的碰撞
# 碰撞，则退出游戏并打印成绩
# 否则，休眠 0.1s

function init_map() {
    # 组装一个数组，数组中的内容代表游戏的元素
    # 0 - 空地
    # 1 - 恐龙（总是在最左边，不会移动）
    # 2 - 树（从右边开始向左边移动，速度越来越快；树的高度和宽度可能不一样）
    for (i = 1; i <= HEIGHT; i++) {
        for (j = 1; j <= WIDTH; j++) {
            map[i][j] = "0";
        }
    }

    map[CURRENT_HEIGHT][1] = "1";
    map[HEIGHT][WIDTH] = "2";
}

function update_sprite_position() {
    for (s = WIDTH; s >= 1; s--) {
        if (map[HEIGHT][s] == "2") {
            # 原先位置元素清空
            map[HEIGHT][s] = "0";

            # 树往左移一个单位
            if (s > 1) {
                map[HEIGHT][s - 1] = "2";
                s--;
            }
        }
    }
}

function update_player_position() {
    if ((getline key < TMP_FILE) > 0) {
        # 判断指令类型，更新用户位置

        # 玩家位置上升
        if (CURRENT_HEIGHT <= HEIGHT) {
            map[CURRENT_HEIGHT][1] = "0"
            map[--CURRENT_HEIGHT][1] = "1"
        }
    }
    # 玩家位置下降
    else {
        if (CURRENT_HEIGHT < HEIGHT) {
            map[CURRENT_HEIGHT][1] = "0"
            map[++CURRENT_HEIGHT][1] = "1"
        }
    }

    # 关闭文件，并清空之前输入的指令
    close(TMP_FILE)
    system(":> " TMP_FILE)
}

function render() {
    system(": > " OUTPUT_FILE)

    for (i = 1; i <= HEIGHT; i++) {
        for (j = 1; j <= WIDTH; j++) {
            if (map[i][j] == "0") {
                printf  "   " >> OUTPUT_FILE # . 代表空地
            } else if (map[i][j] == "1") {
                printf  " D " >> OUTPUT_FILE # D 代表恐龙
            } else if (map[i][j] == "2") {
                printf  " T " >> OUTPUT_FILE # T 代表树
            }
        }

        printf "\n" >> OUTPUT_FILE
    }

    for (j = 1; j <= WIDTH; j++) {
        printf " . " >> OUTPUT_FILE
    }

    printf "\n" >> OUTPUT_FILE
}

function collision_detect() {
    if (map[HEIGHT][1] == "2") {
       return 1
    }

    return 0
}

BEGIN {
    # 定义常量
    TMP_FILE = ".dino_input.tmp"
    OUTPUT_FILE=".dino_output.tmp"
    FRAME_RATE = 1 # 每次循环等待 0.1 秒，约等于 10 FPS
    HEIGHT = 3 # 画布高度
    WIDTH = 10 # 画布宽度
    CURRENT_HEIGHT = HEIGHT

    init_map()

    while (1) {
        # 更新树的位置
        update_sprite_position()
        # 更新玩家的位置
        update_player_position()
        # 渲染
        render()

        # 碰撞判断
        if (collision_detect() > 0) {
            printf "Game Over! You hit a tree!\n" >> OUTPUT_FILE
            exit
        }

        system("sleep 0.5")
    }

    # 游戏主循环
#    while (1) {
#        # 尝试从临时文件中读取一行内容到变量 "key"
#        # getline 返回值: 1 表示成功, 0 表示到文件尾, -1 表示出错
#        if ( (getline key < TMP_FILE) > 0 ) {
#
#            # 如果文件非空，则处理输入
#            if (key != "") {
#                # 在控制台打印出获取到的按键
#                print "Key detected: [" key "]" > OUTPUT_FILE
#
#                # 检查是否为退出键
##                if (key == "q") {
##                    print "Quit signal received. Exiting."
##                    exit # 退出 awk 脚本
##                }
#
#                # 清空临时文件，避免重复读取同一个按键
#                # system() 函数可以执行外部 shell 命令
##                system("echo -n > " TMP_FILE)
#            }
#        }
#
#        # 关闭文件句柄，这一点非常重要。
#        # 如果不关闭，awk 可能会缓存文件状态，导致无法立即感知到文件的下一次更新。
#        close(TMP_FILE)
#
#        # 游戏逻辑更新/屏幕渲染等操作可以放在这里
#        # ...
#
#        # 控制游戏循环速率，防止消耗 100% CPU
#        system("sleep " FRAME_RATE)
#    }
}
