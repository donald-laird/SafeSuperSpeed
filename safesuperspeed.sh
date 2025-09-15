#!/usr/bin/env bash

# 作者: BlueSkyXN
# 优化与重构: Gemini
# 描述: 一个功能完整、安全、带自动清理功能的三网测速脚本。
# 版本: 3.0 (功能与安全最终版)

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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
# 捕获脚本的退出信号，并在接收到信号时执行 cleanup 函数
trap cleanup EXIT INT QUIT TERM

# --- 检查必需的依赖命令 ---
check_dependencies() {
    echo -e "${CYAN}正在检查依赖...${PLAIN}"
    if ! command -v wget &> /dev/null || ! command -v tar &> /dev/null; then
        echo -e "${RED}错误: 必需命令 'wget' 或 'tar' 未找到。${PLAIN}"
        echo -e "${YELLOW}请使用您的包管理器安装它们，例如:${PLAIN}"
        echo "  - Debian/Ubuntu: sudo apt update && sudo apt install wget tar -y"
        echo "  - CentOS/RHEL:   sudo yum install wget tar -y"
        exit 1
    fi
}

# --- 下载并准备 Speedtest-cli ---
setup_speedtest() {
    if [ -e './speedtest-cli/speedtest' ]; then
        return
    fi

    echo -e "${CYAN}正在安装 Speedtest-cli...${PLAIN}"
    local arch
    arch=$(uname -m)
    # 使用更新、更稳定的 v1.2.0
    local speedtest_url="https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-${arch}.tgz"

    if ! wget --no-check-certificate -qO speedtest.tgz "${speedtest_url}"; then
        echo -e "${RED}错误: 下载 Speedtest-cli 失败。请检查您的网络或服务器架构 (${arch}) 是否被支持。${PLAIN}"
        exit 1
    fi

    mkdir -p speedtest-cli
    if ! tar zxf speedtest.tgz -C ./speedtest-cli/ --strip-components=1 > /dev/null 2>&1; then
        echo -e "${RED}错误: 解压 Speedtest-cli 失败。${PLAIN}"
        exit 1
    fi
    chmod a+rx ./speedtest-cli/speedtest
}

# --- 执行单一节点的测速 ---
speed_test() {
    local node_id="$1"
    local node_location="$2"
    local node_isp="$3"
    
    # **关键修复**: 添加 --accept-license 和 --accept-gdpr 参数以跳过交互式许可协议
    ./speedtest-cli/speedtest -p no -s "$node_id" --accept-license --accept-gdpr > ./speedtest.log 2>&1
    
    if grep -q 'Upload' ./speedtest.log; then
        local download_speed upload_speed latency
        download_speed=$(awk '/Download/{print $3}' ./speedtest.log)
        upload_speed=$(awk '/Upload/{print $3}' ./speedtest.log)
        latency=$(awk '/Latency/{print $2}' ./speedtest.log)
        
        printf "${RED}%-6s${YELLOW}%s|${GREEN}%-23s${CYAN}↑ %-10s${BLUE}↓ %-10s${PLAIN}%-8s\n" \
            "${node_id}" "${node_isp}" "${node_location}" "${upload_speed} Mbps" "${download_speed} Mbps" "${latency}"
    else
        printf "${RED}%-6s${YELLOW}%s|${GREEN}%-23s${RED}%s${PLAIN}\n" \
            "${node_id}" "${node_isp}" "${node_location}" "测试失败"
    fi
}

# --- 打印脚本信息 ---
print_intro() {
    echo "————————————————— SuperSpeed (功能修复与安全增强版) —————————————————"
    echo "  本脚本无需Root，自动清理，修复了功能性问题，可安全、稳定使用。"
    echo "—————————————————————————————————————————————————————————————————————"
}

# --- 显示菜单并获取用户选择 ---
select_test() {
    echo -e "  测速类型:    ${GREEN}1.${PLAIN} 三网精华节点    ${GREEN}2.${PLAIN} 取消测速"
    echo -ne "               ${GREEN}3.${PLAIN} 电信          ${GREEN}4.${PLAIN} 联通          ${GREEN}5.${PLAIN} 移动"
    while :; do echo
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
    [[ ${selection} == 2 ]] && echo -e "${YELLOW}已取消测速。${PLAIN}" && exit 0

    echo "—————————————————————————————————————————————————————————————————————"
    echo "ID    运营商|测速节点             上传速度    下载速度    延迟(ms)"
    local start_time
    start_time=$(date +%s)

    # 1. 三网精华节点
    if [[ ${selection} == 1 ]]; then
         speed_test '3633' '上海' '电信'
         speed_test '27594' '广东广州５Ｇ' '电信'
         speed_test '5396' '江苏苏州５Ｇ' '电信'
         speed_test '24447' '上海５Ｇ' '联通'
         speed_test '26678' '广东广州５Ｇ' '联通'
         speed_test '9484' '吉林长春' '联通'
         speed_test '25858' '北京' '移动'
         speed_test '17184' '天津５Ｇ' '移动'
         speed_test '26938' '新疆乌鲁木齐５Ｇ' '移动'
    fi
    
    # 3. 电信
    if [[ ${selection} == 3 ]]; then
         speed_test '3633' '上海' '电信'
         speed_test '27594' '广东广州５Ｇ' '电信'
         speed_test '26352' '江苏南京５Ｇ' '电信'
         speed_test '5396' '江苏苏州５Ｇ' '电信'
         speed_test '29353' '湖北武汉５Ｇ' '电信'
         speed_test '28225' '湖南长沙５Ｇ' '电信'
         speed_test '27377' '北京５Ｇ' '电信'
         speed_test '3973' '甘肃兰州' '电信'
    fi

    # 4. 联通
    if [[ ${selection} == 4 ]]; then
         speed_test '24447' '上海５Ｇ' '联通'
         speed_test '26678' '广东广州５Ｇ' '联通'
         speed_test '13704' '江苏南京' '联通'
         speed_test '5485' '湖北武汉' '联通'
         speed_test '4870' '湖南长沙' '联通'
         speed_test '5145' '北京' '联通'
         speed_test '9484' '吉林长春' '联通'
         speed_test '2461' '四川成都' '联通'
    fi

    # 5. 移动
    if [[ ${selection} == 5 ]]; then
         speed_test '25858' '北京' '移动'
         speed_test '26404' '安徽合肥５Ｇ' '移动'
         speed_test '31520' '广东中山' '移动'
         speed_test '25883' '江西南昌５Ｇ' '移动'
         speed_test '28491' '湖南长沙５Ｇ' '移动'
         speed_test '16171' '福建福州' '移动'
         speed_test '16398' '贵州贵阳' '移动'
         speed_test '25728' '辽宁大连' '移动'
    fi

    local end_time
    end_time=$(date +%s)
    echo "—————————————————————————————————————————————————————————————————————"
    local time_diff=$(( end_time - start_time ))
    if [[ $time_diff -gt 60 ]]; then
        printf "  测试完成, 耗时: %s 分 %s 秒\n" "$((time_diff / 60))" "$((time_diff % 60))"
    else
        printf "  测试完成, 耗时: %s 秒\n" "$time_diff"
    fi
    printf "  当前时间: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
    echo "—————————————————————————————————————————————————————————————————————"
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
