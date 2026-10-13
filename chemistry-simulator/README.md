# Chemistry Simulator: YOLO Apparatus Demo

A local prototype that combines a trained YOLO11n detector for laboratory apparatus with a browser-based chemistry animation demo.

## Included

- `demo/index.html`: browser UI for apparatus detection and two preset reaction animations.
- `demo/server.py`: localhost-only image inference service.
- `demo/start-demo.bat` and `demo/start-demo.ps1`: launchers for Windows + WSL.
- `demo/现场演示操作卡.md`: step-by-step Chinese presentation instructions.
- `runs/apparatus_v1/weights/best.pt`: trained detector checkpoint.
- `runs/apparatus_v1/results.csv`, `results.png`, and `confusion_matrix_normalized.png`: training and validation summaries.

The original 4.49 GB dataset and its archive are not included. Dataset source: [Annotated Chemical Apparatus Image Dataset](https://data.mendeley.com/datasets/8p2hvgdvpn/1), DOI [10.17632/8p2hvgdvpn.1](https://doi.org/10.17632/8p2hvgdvpn.1), licensed CC BY 4.0. The dataset attribution and license should be retained when redistributing dataset-derived materials.

## Results

The YOLO11n model was trained for 30 epochs. Validation metrics: mAP@0.5 **0.8391**, mAP@0.5:0.95 **0.6801**. It detects seven visual classes: hands, conical beakers, Erlenmeyer flasks, reagent bottles, pipettes, eggplant-shaped flasks, and separatory funnels. These metrics describe apparatus detection only; they do not measure chemical understanding.

## Demo scope

The page supports image upload and local YOLO inference, plus two schematic reaction animations:

1. Acetic acid + sodium bicarbonate: gas bubbles.
2. Copper sulfate + sodium hydroxide: pale-blue precipitate.

The local Ollama integration routes equations to one of these presets. It does not validate arbitrary chemistry or generate new reaction mechanisms. Animations are qualitative educational illustrations, not real laboratory procedures or quantitative predictions.

## Running on the original development computer

Requirements: Windows with WSL Ubuntu, the project Python environment at `/home/xiaohui/yolo/.venv`, the trained checkpoint at `runs/apparatus_v1/weights/best.pt`, and Ollama with `qwen3:8b` for the local equation-analysis button.

From the repository root, launch `chemistry-simulator/demo/start-demo.bat` and keep its terminal open. Then open `http://localhost:8765/` in a browser. The demo server binds only to `127.0.0.1`. Start Ollama separately before using local equation analysis. See the presentation card for click-by-click instructions.

For a different computer, install compatible Ultralytics/PyTorch/Pillow dependencies in WSL and update the launcher’s WSL Python path as needed.
