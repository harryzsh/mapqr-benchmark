FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel

WORKDIR /workspace

# Install mmcv-full prebuilt wheel (cp38 + cu116 + torch1.13)
RUN pip install mmcv-full==1.7.2   -f https://download.openmmlab.com/mmcv/dist/cu116/torch1.13.0/index.html

# Install mmdet, mmseg, timm
RUN pip install mmdet==2.28.2 mmsegmentation==0.30.0 timm

# Install mmdet3d
COPY mmdetection3d/ /workspace/mmdetection3d/
RUN cd /workspace/mmdetection3d && python setup.py develop

# Build GKT op
COPY projects/ /workspace/projects/
RUN cd /workspace/projects/mmdet3d_plugin/maptr/modules/ops/geometric_kernel_attn &&     python setup.py build install

# Install runtime deps (av2 with --no-deps to prevent torch overwrite)
RUN pip install nuscenes-devkit==1.1.9 lyft_dataset_sdk     networkx==3.1 numba==0.53.1 llvmlite==0.36.0     plyfile scikit-image shapely einops     matplotlib==3.5.2 trimesh pyquaternion descartes &&     pip install av2 --no-deps &&     pip install "numpy==1.23.5" --force-reinstall --no-deps

# Patch mmdet3d version check
RUN python - << PYEOF
path = "/workspace/mmdetection3d/mmdet3d/__init__.py"
with open(path) as f: lines = f.readlines()
new = ["# "+l if any(x in l for x in ["mmcv_maximum_version","mmcv_minimum_version","mmcv_version","assert (mmcv","and mmcv_version","MMCV==","Please install mmcv"]) else l for l in lines]
open(path,"w").writelines(new)
PYEOF

