#!/bin/bash

L1_InstrPerf=(
    # "no"
    # "D_JOLT"
    # "D_JOLT_LR_Dist_13"
    # "D_JOLT_LR_Dist_14"
    # "D_JOLT_LR_Dist_16"
    # "D_JOLT_LR_Dist_17"
    # "D_JOLT_LR_HistLen_5"
    # "D_JOLT_LR_HistLen_6"
    # "D_JOLT_LR_HistLen_8"
    # "D_JOLT_LR_HistLen_9"
    # "D_JOLT_size_2way"
    # "D_JOLT_size_8way"
    # "EIP"
    # "EIP_BBsize_5"
    # "EIP_BBsize_6"
    # "EIP_BBsize_8"
    # "EIP_BBsize_9"
    # "EIP_Conf_Th_2"
    # "EIP_Conf_Th_3"
    # "EIP_size_14way"
    # "EIP_size_71way"
    "EIP_Formats_5"
    "EIP_Formats_4"
    "EIP_Formats_3"
    "EIP_Formats_2"
    )


topTraces=(
    "client_004.champsimtrace.xz"
    "server_003.champsimtrace.xz"
    "spec_gcc_001.champsimtrace.xz"
    "spec_gobmk_001.champsimtrace.xz"
    "spec_gobmk_002.champsimtrace.xz")

allTraces=(
    "client_001.champsimtrace.xz"
    "client_002.champsimtrace.xz"
    "client_003.champsimtrace.xz"
    "client_004.champsimtrace.xz"
    "client_005.champsimtrace.xz"
    "client_006.champsimtrace.xz"
    "client_007.champsimtrace.xz"
    "client_008.champsimtrace.xz"
    "server_001.champsimtrace.xz"
    "server_002.champsimtrace.xz"
    "server_003.champsimtrace.xz"
    "server_004.champsimtrace.xz"
    "server_009.champsimtrace.xz"
    "server_010.champsimtrace.xz"
    "server_011.champsimtrace.xz"
    "server_012.champsimtrace.xz"
    "server_013.champsimtrace.xz"
    "server_014.champsimtrace.xz"
    "server_015.champsimtrace.xz"
    "server_016.champsimtrace.xz"
    "server_017.champsimtrace.xz"
    "server_018.champsimtrace.xz"
    "server_019.champsimtrace.xz"
    "server_020.champsimtrace.xz"
    "server_021.champsimtrace.xz"
    "server_022.champsimtrace.xz"
    "server_023.champsimtrace.xz"
    "server_024.champsimtrace.xz"
    "server_025.champsimtrace.xz"
    "server_026.champsimtrace.xz"
    "server_027.champsimtrace.xz"
    "server_028.champsimtrace.xz"
    "server_029.champsimtrace.xz"
    "server_030.champsimtrace.xz"
    "server_031.champsimtrace.xz"
    "server_032.champsimtrace.xz"
    "server_033.champsimtrace.xz"
    "server_034.champsimtrace.xz"
    "server_035.champsimtrace.xz"
    "server_036.champsimtrace.xz"
    "server_037.champsimtrace.xz"
    "server_038.champsimtrace.xz"
    "server_039.champsimtrace.xz"
    "spec_gcc_001.champsimtrace.xz"
    "spec_gcc_002.champsimtrace.xz"
    "spec_gcc_003.champsimtrace.xz"
    "spec_gobmk_001.champsimtrace.xz"
    "spec_gobmk_002.champsimtrace.xz"
    "spec_perlbench_001.champsimtrace.xz"
    "spec_x264_001.champsimtrace.xz")


function get_Binary_Name() {
    # Arguments -> l1i_pref_array, return_array
    local -n l1i_pref_array=$1
    local -n binaryName=$2
    unset binaryName
    for i in ${!l1i_pref_array[@]}; do
        binaryName[$i]="hashed_perceptron-"
        binaryName[$i]+=${l1i_pref_array[$i]}
        binaryName[$i]+="-next_line-spp_dev-no-lru-1core"
    done
}

function compile() {
    # Arguments -> l1i_pref_array
    # cannot be parallelized
    local -n l1i_pref_array=$1
    
    echo "-----------------------------------"
    echo "-------- Started Compiling --------"
    echo "-----------------------------------"

    for i in ${!l1i_pref_array[@]}; do
        echo "Compiling ${i}: ${l1i_pref_array[$i]}"
        ./build_champsim.sh hashed_perceptron ${l1i_pref_array[$i]} next_line spp_dev no lru 1
    done
}

# initialize a semaphore with a given number of tokens
open_sem() {
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}

# run the given command asynchronously and pop/push tokens
run_with_lock() {
    local x
    # this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3
    )&
}

function run() {
    # Arguments -> l1i_pref_array
    local -n trace_list=$1
    local -n binaryName=$2
    local -n threadCount=$3

    echo "---------------------------------"
    echo "-------- Started Running --------"
    echo "---------------------------------"

    open_sem $threadCount
    for i in ${!binaryName[@]}; do
        echo "Binary $i: ${binaryName[$i]}"
        for j in ${!trace_list[@]}; do
            echo "Trace ${j}: ${trace_list[$j]}"
            run_with_lock ./run_champsim.sh ${binaryName[$i]} 50 50 ${trace_list[$j]}
        done
        echo " "
    done
}

binName=()
numThreads=8

get_Binary_Name L1_InstrPerf binName
compile L1_InstrPerf
run allTraces binName numThreads