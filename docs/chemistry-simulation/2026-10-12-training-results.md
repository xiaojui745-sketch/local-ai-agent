# Chemistry apparatus YOLO training results — 2026-10-12

## What was completed

A YOLO11n object detector was trained on the Mendeley **Annotated Chemical Apparatus Image Dataset**. The data is in the local project at `D:\YOLO\chemistry_sim`; the dataset archive and images are not included in this GitHub repository.

- Dataset: 5,078 annotated images, in YOLO format; 4,303 train, 570 validation, 205 test images.
- Classes: hand, conical beaker, Erlenmeyer flask, reagent bottle, pipette, eggplant-shaped flask, separatory funnel.
- Training: Ultralytics YOLO11n, pretrained initialization, 30 epochs, image size 640, batch 8, CUDA device 0 (NVIDIA GeForce RTX 5060 Laptop GPU).
- Validation at epoch 30: precision 0.8437, recall 0.7640, mAP@0.5 0.8391, mAP@0.5:0.95 0.6801.
- Checkpoints: `D:\YOLO\chemistry_sim\runs\apparatus_v1\weights\best.pt` and `last.pt` (about 5.3 MB each).
- Inference was run on the 205-image test split; predictions were saved locally under `D:\YOLO\chemistry_sim\runs\apparatus_test`. This run did not calculate or report aggregate test metrics.

## Interpretation and limits

This is a useful apparatus-and-hand detection baseline. It does **not** identify chemical substances, infer reaction products, or detect color change, precipitate formation, or gas evolution. Those need separate labeled datasets and a chemistry knowledge/rules layer. The current validation score should not be presented as proof of reaction-simulation capability.

A plotting step reported `OSError: [Errno 12] Cannot allocate memory` after inference/validation output. The training metrics were recorded in `results.csv`, and both checkpoints were present; the issue affected plot generation, not checkpoint existence.

## Source and attribution

Ryosuke Sasaki, Mikito Fujinami, and Hiromi Nakai, “Annotated Chemical Apparatus Image Dataset,” Mendeley Data, version 1 (2023), DOI: [10.17632/8p2hvgdvpn.1](https://doi.org/10.17632/8p2hvgdvpn.1). The dataset page lists the dataset as **CC BY 4.0**. Attribute the creators and source and retain the license when redistributing dataset-derived materials. The 4.5 GB dataset itself remains on the user's D: drive and is not uploaded here.

## Reproduction notes

The dataset YAML and training run are local to `D:\YOLO\chemistry_sim`. The training configuration used `yolo11n.pt`, `chemistry_apparatus.yaml`, 30 epochs, `imgsz=640`, `batch=8`, `device=0`, with the run name `apparatus_v1`. Do not commit the raw dataset or generated checkpoints into this repository without reviewing repository storage and licensing choices first.

## Next step

Before expanding to chemical phases, review licensing and inspect a phase-annotated dataset such as [HeinSight4.0 v2](https://zenodo.org/records/15605098). Its record describes phase labels for solid, homogeneous/heterogeneous liquid, residue, and air; the visible Zenodo page does not show a license, so obtain/verify reuse terms before downloading for training or redistribution.
