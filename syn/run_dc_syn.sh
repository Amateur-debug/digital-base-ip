#!/bin/bash

#BSUB -J dc_syn     # 作业名称
#BSUB -q cpu        # 要提交到的队列（这里假设用 CPU 队列）
#BSUB -n 32         # 申请CPU核数 (仅供示例，可根据实际需要调整)
#BSUB -o dc.log     # 标准输出重定向文件
#BSUB -e dc.log     # 错误输出重定向文件
#BSUB -W 04:00      # 申请的最长运行时间 (hh:mm)，仅供示例

# 如果需要额外的环境配置（比如license、环境变量等），可在这里加载
module load dc/2023.12  # (示例命令，具体以实际环境为准)
module load lic/eda

# 执行DC命令 
exec > dc.log 2>&1
dc_shell -f dc_syn.tcl

