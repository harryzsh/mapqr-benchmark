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
