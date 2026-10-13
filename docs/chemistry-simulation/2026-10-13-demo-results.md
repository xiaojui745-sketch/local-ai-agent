# Chemistry simulator demo — 2026-10-13

## Deliverables added to this repository

- Local web demo with YOLO image upload/inference and preset reaction animations.
- Trained YOLO11n checkpoint (`best.pt`, 5.48 MB).
- Training/validation curve, normalized confusion matrix, and `results.csv`.
- Windows + WSL launch scripts and a Chinese click-by-click presentation guide.
- Dataset attribution and model limitations in `README.md` and `MODEL_CARD.md`.

## Verified outcomes

- YOLO11n trained for 30 epochs. Validation: precision 0.8437, recall 0.7640, mAP@0.5 0.8391, mAP@0.5:0.95 0.6801.
- The local web app returned detections for uploaded dataset test images; one conical beaker example was detected at about 91.9% confidence.
- The Ollama `qwen3:8b` local API selected the gas and precipitate presets for the two supported equations.
- Both preset animations played through: acetic acid + sodium bicarbonate (gas bubbles), and copper sulfate + sodium hydroxide (pale-blue precipitate).

These results demonstrate a working prototype, not general chemical reasoning. The local model routes only to the two preset animations; it does not validate arbitrary reactions or generate new animations. The detector identifies apparatus/hands, not chemicals or reaction outcomes.

## Data omitted

The original 4.49 GB dataset archive, extracted images/labels, and bulk test predictions are intentionally not in GitHub. Dataset source and CC BY 4.0 attribution are recorded in the subproject README and model card.
