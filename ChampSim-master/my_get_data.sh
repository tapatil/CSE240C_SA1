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

function get_IPC() {
    # Arguments -> l1i_pref_array, trace_list
    local -n l1i_pref_array=$1
    local -n trace_list=$2
    local -n binaryName=$3
    local resultsDir=$PWD/$4

    declare -a ipc_array

    for i in ${!l1i_pref_array[@]}; do

        echo "L1 instr Prefetcher Name: ${l1i_pref_array[$i]}"
        for j in ${!trace_list[@]}; do
            path=$resultsDir/${trace_list[$j]}-${binaryName[$i]}.txt
            lineNum="$(grep -n "CPU 0 cumulative IPC:" $path | head -n 1 | cut -d: -f1)"
            ipc_array[$j]=$(awk -v dataLine="$lineNum" 'NR==dataLine{print $5}' $path)
            echo "Trace No. ${j}: ${trace_list[$j]} - IPC: ${ipc_array[$j]}"
        done
        echo " "

        # for j in ${!trace_list[@]}; do
        #     echo "${ipc_array[$j]} - ${trace_list[$j]}"
        # done > _IPC_${binaryName[$i]}.txt

        for j in ${!trace_list[@]}; do
            echo "${ipc_array[$j]}"
        done > __IPC_${binaryName[$i]}.txt
    done
}

function get_MPKI() {
    # Arguments -> l1i_pref_array, trace_list
    local -n l1i_pref_array=$1
    local -n trace_list=$2
    local -n binaryName=$3
    local resultsDir=$PWD/$4

    declare -a mpki_array

    for i in ${!l1i_pref_array[@]}; do

        echo "L1 instr Prefetcher Name: ${l1i_pref_array[$i]}"
        for j in ${!trace_list[@]}; do
            path=$resultsDir/${trace_list[$j]}-${binaryName[$i]}.txt
            lineNum="$(grep -n "MPKI:" $path | head -n 1 | cut -d: -f1)"
            mpki_array[$j]=$(awk -v dataLine="$lineNum" 'NR==dataLine{print $8}' $path)
            echo "Trace No. ${j}: ${trace_list[$j]} - MPKI: ${mpki_array[$j]}"
        done
        echo " "

        # for j in ${!trace_list[@]}; do
        #     echo "${mpki_array[$j]} - ${trace_list[$j]}"
        # done > _IPC_${binaryName[$i]}.txt

        for j in ${!trace_list[@]}; do
            echo "${mpki_array[$j]}"
        done > __MPKI_${binaryName[$i]}.txt
    done
}


binName=()

get_Binary_Name L1_InstrPerf binName
get_IPC L1_InstrPerf allTraces binName results_50M_EIP_dest_blocks
get_MPKI L1_InstrPerf allTraces binName results_50M_EIP_dest_blocks