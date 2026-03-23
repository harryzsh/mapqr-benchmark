#!/bin/bash
# setup_env.sh - Fresh environment for MapQR on CUDA 12.x systems
set -e
exec > /opt/dlami/nvme/setup.log 2>&1

source /opt/conda/etc/profile.d/conda.sh

echo "[$(date)] Step 1: Remove any existing broken env"
conda env remove -n mapqr -y 2>/dev/null || true

echo "[$(date)] Step 2: Create fresh Python 3.9 env WITH cudatoolkit 11.7"
# cudatoolkit=11.7 provides libcudart.so.11.0 and other CUDA 11.7 runtime libs
# This makes mmcv-full 1.x prebuilt wheels work even on CUDA 12.x systems
conda create -n mapqr python=3.9 cudatoolkit=11.7 -c nvidia -c conda-forge -y

PIP=/opt/conda/envs/mapqr/bin/pip
PY=/opt/conda/envs/mapqr/bin/python

echo "[$(date)] Step 3: Install torch 1.13.1+cu117"
$PIP install torch==1.13.1+cu117 torchvision==0.14.1+cu117 \
  -f https://download.pytorch.org/whl/torch_stable.html

echo "[$(date)] Step 4: Install mmcv-full 1.6.0 (prebuilt wheel - no compilation)"
$PIP install mmcv-full==1.6.0 \
  -f https://download.openmmlab.com/mmcv/dist/cu117/torch1.13.0/index.html

echo "[$(date)] Step 5: Verify torch + mmcv before continuing"
$PY -c "import torch; import mmcv; from mmcv.ops import MultiScaleDeformableAttention; print(torch:, torch.__version__, mmcv:, mmcv.__version__, CUDA:, torch.cuda.is_available())"

echo "[$(date)] Step 6: Install mmdet, mmseg, timm"
$PIP install mmdet==2.28.2 mmsegmentation==0.30.0 timm

echo "[$(date)] Step 7: Install mmdet3d (MapQR bundled submodule)"
cd /opt/dlami/nvme/MapQR/mmdetection3d
$PY setup.py develop

echo "[$(date)] Step 8: Build geometric kernel attention CUDA op"
cd /opt/dlami/nvme/MapQR/projects/mmdet3d_plugin/maptr/modules/ops/geometric_kernel_attn
$PY setup.py build install

echo "[$(date)] Step 9: Install all runtime dependencies"
$PIP install \
  nuscenes-devkit==1.1.9 lyft_dataset_sdk av2 \
  networkx==3.1 numba==0.53.1 llvmlite==0.36.0 \
  plyfile scikit-image shapely einops \
  matplotlib==3.5.2 trimesh pyquaternion descartes

# CRITICAL: Pin numpy last - nuscenes-devkit pulls in numpy 2.x which breaks torch
$PIP install "numpy==1.23.5" --force-reinstall --no-deps

echo "[$(date)] Step 10: Full import verification"
export PYTHONPATH=/opt/dlami/nvme/MapQR:/opt/dlami/nvme/MapQR/mmdetection3d:$PYTHONPATH
$PY /opt/dlami/nvme/mapqr-benchmark/scripts/verify_imports.py

echo "[$(date)] === SETUP COMPLETE ==="
