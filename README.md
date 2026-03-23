# MapQR GPU Benchmark on AWS g5.48xlarge

Benchmarking [MapQR](https://github.com/HXMap/MapQR) (HD map perception, ECCV 2024) on AWS g5.48xlarge (8x NVIDIA A10G), following the same methodology as the [H200 Pluto benchmark](https://github.com/yunfeilu92/h200-benchmark).

## Infrastructure

| Item | Detail |
|------|--------|
| Instance | g5.48xlarge |
| GPUs | 8x NVIDIA A10G (24 GB VRAM each) |
| GPU TDP | 300W each |
| Region | us-east-1 |
| AMI | Deep Learning OSS Nvidia Driver AMI GPU PyTorch 2.5.1 (Ubuntu 22.04) |
| Storage | 500GB EBS root + 6.9TB local NVMe (all data/code on NVMe) |

## Algorithm & Dataset

| Item | Detail |
|------|--------|
| Repo | https://github.com/HXMap/MapQR |
| Task | Online HD Map Construction (Perception) |
| Model | ResNet-50 backbone + BEV encoder + Transformer decoder (~50M params) |
| Dataset | nuScenes v1.0 (mini for validation, trainval for benchmark) |
| Framework | PyTorch + mmdetection3d |

## Environment (Correct Stack)

```
Python:          3.9
PyTorch:         1.13.1+cu117
torchvision:     0.14.1+cu117
cudatoolkit:     11.7 (installed via conda - provides runtime libs)
mmcv-full:       1.6.0 (prebuilt for torch1.13+cu117)
mmdet:           2.28.2
mmsegmentation:  0.30.0
mmdet3d:         0.17.2 (MapQR bundled submodule)
nuscenes-devkit: 1.1.9
numba:           0.53.1
numpy:           1.23.5
```

> **Key insight**: Install `cudatoolkit=11.7` via conda alongside torch 1.13+cu117.
> This provides all CUDA 11.7 runtime libraries inside the conda env,
> making mmcv-full prebuilt wheels work regardless of the system CUDA version (12.x).

## Setup Steps

### 1. Launch Instance
```bash
# g5.48xlarge in public subnet with Deep Learning AMI
# Attach SSM IAM role for remote access
# 500GB gp3 EBS root volume
```

### 2. Clone MapQR
```bash
cd /opt/dlami/nvme
git clone --recurse-submodules https://github.com/HXMap/MapQR.git
```

### 3. Install Environment
```bash
bash scripts/setup_env.sh
```

### 4. Download Dataset
```bash
# nuScenes is publicly available on S3 - no login required
bash scripts/download_nuscenes.sh
```

### 5. Prepare Dataset
```bash
bash scripts/prepare_data.sh
```

### 6. Run Baseline Training + Monitor
```bash
bash scripts/run_benchmark.sh
```

## Benchmark Results

| Config | Epoch Time | GPU Util | VRAM | Temp | Power |
|--------|-----------|----------|------|------|-------|
| 8x A10G FP32 bs=default | TBD | TBD | TBD | TBD | TBD |
| 8x A10G FP32 bs=large | TBD | TBD | TBD | TBD | TBD |
| 8x A10G BF16 bs=large | TBD | TBD | TBD | TBD | TBD |

## Comparison with H200 Benchmark (Pluto)

| | H200 (Pluto) | A10G (MapQR) |
|--|--|--|
| Task | Planning | Perception (Map Construction) |
| Model params | 4M | ~50M |
| GPU VRAM | 144 GB/card | 24 GB/card |
| GPU TDP | 700W | 300W |
| Dataset | nuPlan | nuScenes |
