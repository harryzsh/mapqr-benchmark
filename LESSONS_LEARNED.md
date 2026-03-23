# Lessons Learned

## 1. Never upgrade Python in-place inside a conda env
Always conda env remove + conda create fresh. Upgrading Python breaks all compiled packages.

## 2. Install cudatoolkit via conda to fix CUDA library issues
When mmcv-full 1.x prebuilt wheels fail with libcudart.so.11.0 not found on CUDA 12.x systems:
  conda create -n mapqr python=3.9 cudatoolkit=11.7 -c nvidia -c conda-forge -y
This installs CUDA 11.7 runtime libs inside the conda env.

## 3. mmcv-full 1.x prebuilt wheels only exist for torch <= 1.13
For MapQR (requires mmcv 1.x API), use: torch==1.13.1+cu117 + mmcv-full==1.6.0
There are NO prebuilt mmcv-full 1.x wheels for torch 2.x.

## 4. Pin numpy LAST after all other installs
nuscenes-devkit pulls in numpy 2.x which breaks torch compiled for numpy 1.x.
  pip install numpy==1.23.5 --force-reinstall --no-deps
Run this as the very last pip command.

## 5. The nuScenes converter appends -trainval to the version arg
The __main__ block does: train_version = f{args.version}-trainval
For mini, patch it: train_version = args.version if mini in args.version else f{args.version}-trainval

## 6. nuScenes is publicly available on S3 - no login needed
s3://motional-nuscenes/public/v1.0/ with --no-sign-request
Same pattern as nuPlan: s3://motional-nuplan/public/nuplan-v1.1/

## 7. Verify ALL imports before running training
Write a verify_imports.py and run it first. Catches missing packages before wasting time.

## 8. Deploy EC2 into a public subnet explicitly
Check MapPublicIpOnLaunch before launching. Private subnets have no public IP.

## 9. Never share credentials in chat
Revoke any accidentally shared tokens immediately at https://github.com/settings/tokens

## 10. Use Docker for old research code on modern CUDA systems

**Problem**: MapQR requires CUDA 11.x (runtime + compiler) but DLAMI has CUDA 12.4.
conda cudatoolkit provides runtime libs only - no nvcc compiler.
Result: mmdet3d CUDA ops fail to compile with "CUDA version mismatch" error.

**Fix**: Use Docker with the matching PyTorch image:

==========
== CUDA ==
==========

CUDA Version 11.6.2

Container image Copyright (c) 2016-2022, NVIDIA CORPORATION & AFFILIATES. All rights reserved.

This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

A copy of this license is made available in this container at /NGC-DL-CONTAINER-LICENSE for your convenience.
Inside the container: CUDA 11.6 runtime + nvcc compiler = no mismatch.
Host CUDA 12.4 driver still talks to GPU hardware (backward compatible).
GPU performance is identical to bare metal - no overhead.

## 11. av2 package pulls in torch 2.x - install with --no-deps

Collecting av2
  Downloading av2-0.3.6-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (4.7 kB)
Downloading av2-0.3.6-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (15.2 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 15.2/15.2 MB 76.0 MB/s  0:00:00
Installing collected packages: av2
Successfully installed av2-0.3.6

## 12. mmcv-full 1.x prebuilt wheels only exist for Python 3.7/3.8

For Python 3.9+, you must build from source - which requires matching nvcc.
This is why Docker (with Python 3.8 base image) is the cleanest solution.
