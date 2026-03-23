#!/bin/bash
set -e
source /opt/conda/etc/profile.d/conda.sh && conda activate mapqr
export PYTHONPATH=/opt/dlami/nvme/MapQR:/opt/dlami/nvme/MapQR/mmdetection3d:$PYTHONPATH
cd /opt/dlami/nvme/MapQR

# Start GPU monitor
bash /opt/dlami/nvme/mapqr-benchmark/scripts/gpu_monitor.sh &
GPU_PID=$!

echo "[$(date)] Baseline: 8x A10G FP32 default batch"
bash tools/dist_train.sh projects/configs/mapqr/mapqr_nusc_r50_24ep.py 8

kill $GPU_PID 2>/dev/null
echo "[$(date)] Done. Results in gpu_monitor.log"
awk -F, NR
