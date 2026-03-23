#!/bin/bash
# gpu_monitor.sh - Continuous GPU monitoring
echo "timestamp,gpu,util%,mem_used_mb,mem_total_mb,temp_c,power_w,power_limit_w" > gpu_monitor.log
while true; do
  nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw,power.limit \
    --format=csv,noheader,nounits | awk -F"," -v ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "{print ts","$1","$2","$3","$4","$5","$6","$7}"
  sleep 5
done >> gpu_monitor.log
