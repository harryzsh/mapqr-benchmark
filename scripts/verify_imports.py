import sys
sys.path.insert(0, "/opt/dlami/nvme/MapQR")
sys.path.insert(0, "/opt/dlami/nvme/MapQR/mmdetection3d")

all_ok = True
for mod in ["torch", "mmcv", "mmdet3d", "nuscenes", "numba", "av2", "einops", "trimesh", "shapely"]:
    try:
        m = __import__(mod)
        print("OK:", mod, getattr(m, "__version__", ""))
    except Exception as e:
        print("FAIL:", mod, "-", str(e)[:80])
        all_ok = False

import torch
print("CUDA:", torch.cuda.is_available(), "GPUs:", torch.cuda.device_count())

try:
    from mmcv.ops import MultiScaleDeformableAttention
    print("OK: mmcv CUDA ops")
except Exception as e:
    print("FAIL: mmcv CUDA ops -", str(e)[:80])
    all_ok = False

try:
    from mmdet3d.datasets import build_dataset
    print("OK: mmdet3d.datasets")
except Exception as e:
    print("FAIL: mmdet3d.datasets -", str(e)[:80])
    all_ok = False

if all_ok:
    print("\n=== ALL IMPORTS OK ===")
else:
    print("\n=== SOME IMPORTS FAILED ===")
    sys.exit(1)
