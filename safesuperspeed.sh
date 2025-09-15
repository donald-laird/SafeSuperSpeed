#!/usr/bin/env bash

# 作者: BlueSkyXN
# 优化: Gemini
# 描述: 一个更安全、带自动清理功能的三网测速脚本。

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'

# --- 清理函数 ---
# 无论脚本如何退出（正常完成、手动中断或出错），此函数都会被执行
cleanup() {
    echo -e "\n${YELLOW}正在清理临时文件...${PLAIN}"
    rm -rf speedtest.tgz speedtest-cli speedtest.log
    echo -e "${GREEN}清理完成。${PLAIN}"
}

# --- 陷阱命令 (Trap) ---
# 捕获脚本的退出信号（EXIT）、中断信号（INT）、退出信号（QUIT）、终止信号（TERM）
# 并在接收到这些信号时，执行 cleanup 函数
trap cleanup EXIT INT QUIT TERM

# --- 检查必需的依赖命令 ---
check_dependencies() {
    local missing_deps=0
    echo -e "${CYAN}正在检查依赖...${PLAIN}"
    for cmd in wget tar; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${RED}错误: 必需命令 '$cmd' 未找到。请使用您的包管理器 (如 'apt install $cmd' 或 'yum install $cmd') 安装它。${PLAIN}"
            missing_deps=1
        fi
    done

    if [ "$missing_deps" -eq 1 ]; then
        # 由于trap的存在，这里退出也会触发cleanup
        exit 1
    fi
}

# --- 下载并准备 Speedtest-cli ---
setup_speedtest() {
    if [ -e './speedtest-cli/speedtest' ]; then
        echo -e "${GREEN}Speedtest-cli 已存在, 跳过下载。${PLAIN}"
        return
    fi

    echo -e "${CYAN}正在安装 Speedtest-cli...${PLAIN}"
    local arch
    arch=$(uname -m)
    local speedtest_url="https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-${arch}.tgz"

    # 使用 wget 下载，并进行错误检查
    if ! wget --no-check-certificate -qO speedtest.tgz "${speedtest_url}"; then
        echo -e "${RED}错误: 下载 Speedtest-cli 失败。请检查您的网络或架构 (${arch}) 是否被支持。${PLAIN}"
        exit 1
    fi

    # 创建目录并解压，进行错误检查
    mkdir -p speedtest-cli
    if ! tar zxf speedtest.tgz -C ./speedtest-cli/ > /dev/null 2>&1; then
        echo -e "${RED}错误: 解压 Speedtest-cli 失败。${PLAIN}"
        exit 1
    fi

    # 赋予执行权限
    chmod a+rx ./speedtest-cli/speedtest
}

# --- 执行单一节点的测速 ---
speed_test() {
    local node_id="$1"
    local node_location="$2"
    local node_isp="$3"
    
    # 运行测速命令，并将输出重定向到日志文件
    ./speedtest-cli/speedtest -p no -s "$node_id" --accept-license --accept-gdpr > ./speedtest.log 2>&1
    
    # 检查日志中是否包含 'Upload' 关键词，以判断测速是否成功
    if grep -q 'Upload' ./speedtest.log; then
        local download_speed
        local upload_speed
        local latency
        download_speed=$(awk -F ' ' '/Download/{print $3}' ./speedtest.log)
        upload_speed=$(awk -F ' ' '/Upload/{print $3}' ./speedtest.log)
        latency=$(awk -F ' ' '/Latency/{print $2}' ./speedtest.log)
        
        # 格式化输出
        printf "${RED}%-6s${YELLOW}%s%s${GREEN}%-24s${CYAN}%s%-10s${BLUE}%s%-10s${PURPLE}%-8s${PLAIN}\n" \
            "${node_id}" "${node_isp}" "|" "${node_location}                    " \
            "↑ " "${upload_speed}" "↓ " "${download_speed}" "${latency}"
    else
        # 如果测速失败，则打印错误信息
        printf "${RED}%-6s${YELLOW}%s%s${GREEN}%-24s${RED}%s${PLAIN}\n" \
            "${node_id}" "${node_isp}" "|" "${node_location}                    " \
            "测试失败"
    fi
}

# --- 打印脚本信息 ---
print_intro() {
    echo "——————————————————— SuperSpeed 安全优化版 ——————————————————"
    echo "  本脚本移除了Root要求，并增加了自动清理机制，可以安全使用"
    echo "——————————————————————————————————————————————————————————"
}

# --- 显示菜单并获取用户选择 ---
select_test() {
    echo -e "  测速类型:    ${GREEN}1.${PLAIN} 三网测速    ${GREEN}2.${PLAIN} 取消测速"
    echo -ne "               ${GREEN}3.${PLAIN} 电信节点    ${GREEN}4.${PLAIN} 联通节点    ${GREEN}5.${PLAIN} 移动节点"
    while :; do echo
            # **FIX**: Read from /dev/tty to ensure it works even when stdin is redirected.
            read -p "  请输入数字选择测速类型 [1-5]: " selection < /dev/tty
            if [[ ! $selection =~ ^[1-5]$ ]]; then
                echo -ne "  ${RED}输入错误${PLAIN}, 请输入正确的数字!"
            else
                break   
            fi
    done
}

# --- 根据用户选择运行测试 ---
run_test() {
    # 如果用户选择 2，则脚本会正常退出，并触发 cleanup
    [[ ${selection} == 2 ]] && echo -e "${YELLOW}已取消测速。${PLAIN}" && exit 0

    echo "——————————————————————————————————————————————————————————"
    echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
    local start_time
    start_time=$(date +%s)

    # 三网测速
    if [[ ${selection} == 1 ]]; then
         speed_test '3633' '上海' '电信'
         speed_test '27594' '广东广州５Ｇ' '电信'
         speed_test '5396' '江苏苏州５Ｇ' '电信'
         speed_test '29353' '湖北武汉５Ｇ' '电信'
         speed_test '24447' '上海５Ｇ' '联通'
         speed_test '26678' '广东广州５Ｇ' '联通'
         speed_test '5485' '湖北武汉' '联通'
         speed_test '4870' '湖南长沙' '联通'
         speed_test '25858' '北京' '移动'
         speed_test '17184' '天津５Ｇ' '移动'
         speed_test '26938' '新疆乌鲁木齐５Ｇ' '移动'
         speed_test '16398' '贵州贵阳' '移动'
    fi
    
    # 电信
    if [[ ${selection} == 3 ]]; then
         speed_test '3633' '上海' '电信'
         speed_test '24012' '内蒙古呼和浩特' '电信'
         speed_test '27377' '北京５Ｇ' '电信'
         speed_test '29026' '四川成都' '电信'
         speed_test '17145' '安徽合肥５Ｇ' '电信'
         speed_test '27594' '广东广州５Ｇ' '电信'
         speed_test '26352' '江苏南京５Ｇ' '电信'
         speed_test '5396' '江苏苏州５Ｇ' '电信'
         speed_test '7509' '浙江杭州' '电信'
         speed_test '29353' '湖北武汉５Ｇ' '电信'
         speed_test '28225' '湖南长沙５Ｇ' '电信'
         speed_test '3973' '甘肃兰州' '电信'
    fi

    # 联通
    if [[ ${selection} == 4 ]]; then
         speed_test '24447' '上海５Ｇ' '联通'
         speed_test '5145' '北京' '联通'
         speed_test '2461' '四川成都' '联通'
         speed_test '27154' '天津５Ｇ' '联通'
         speed_test '26180' '山东济南５Ｇ' '联通'
         speed_test '26678' '广东广州５Ｇ' '联通'
         speed_test '13704' '江苏南京' '联通'
         speed_test '5485' '湖北武汉' '联通'
         speed_test '4870' '湖南长沙' '联通'
         speed_test '4884' '福建福州' '联通'
         speed_test '4863' '陕西西安' '联通'
    fi

    # 移动
    if [[ ${selection} == 5 ]]; then
         speed_test '25858' '北京' '移动'
         speed_test '17184' '天津５Ｇ' '移动'
         speed_test '31520' '广东中山' '移动'
         speed_test '26938' '新疆乌鲁木齐５Ｇ' '移动'
         speed_test '25883' '江西南昌５Ｇ' '移动'
         speed_test '26331' '河南郑州５Ｇ' '移动'
         speed_test '28491' '湖南长沙５Ｇ' '移动'
         speed_test '16171' '福建福州' '移动'
         speed_test '16398' '贵州贵阳' '移动'
         speed_test '25728' '辽宁大连' '移动'
    fi

    local end_time
    end_time=$(date +%s)
    echo "——————————————————————————————————————————————————————————"
    local time_diff=$(( end_time - start_time ))
    if [[ $time_diff -gt 60 ]]; then
        local min=$(( time_diff / 60 ))
        local sec=$(( time_diff % 60 ))
        echo -ne "  测试完成, 耗时: ${min} 分 ${sec} 秒"
    else
        echo -ne "  测试完成, 耗时: ${time_diff} 秒"
    fi
    echo -ne "\n  当前时间: "
    date '+%Y-%m-%d %H:%M:%S'
    echo "——————————————————————————————————————————————————————————"
}

# --- 主函数 ---
main() {
    clear
    check_dependencies
    setup_speedtest
    print_intro
    select_test
    run_test
}

# --- 脚本入口 ---
main

