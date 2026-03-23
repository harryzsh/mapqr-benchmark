#!/bin/bash
set -e
source /opt/conda/etc/profile.d/conda.sh && conda activate mapqr
export PYTHONPATH=/opt/dlami/nvme/MapQR:/opt/dlami/nvme/MapQR/mmdetection3d:$PYTHONPATH
cd /opt/dlami/nvme/MapQR

# Patch converter: the __main__ block appends -trainval to version arg
# For mini we need to pass version directly
sed -i "s/train_version = f.{args.version}-trainval./train_version = args.version if mini in args.version else f{args.version}-trainval/" \
  tools/maptrv2/custom_nusc_map_converter.py 2>/dev/null || true

echo "[$(date)] Generating mini pkl..."
/opt/conda/envs/mapqr/bin/python tools/maptrv2/custom_nusc_map_converter.py \
  --root-path ./data/nuscenes --out-dir ./data/nuscenes \
  --extra-tag nuscenes --version v1.0-mini --canbus ./data

echo "[$(date)] Generating trainval pkl..."
/opt/conda/envs/mapqr/bin/python tools/maptrv2/custom_nusc_map_converter.py \
  --root-path ./data/nuscenes --out-dir ./data/nuscenes \
  --extra-tag nuscenes --version v1.0 --canbus ./data

ls -lh ./data/nuscenes/*.pkl
