# Model card: laboratory apparatus detector

- Architecture: YOLO11n object detector.
- Training: 30 epochs on the train split of the dataset below.
- Validation: mAP@0.5 0.8391; mAP@0.5:0.95 0.6801.
- Classes: hand, conical_beaker, erlenmeyer_flask, reagent_bottle, pipette, eggplant_shaped_flask, separatory_funnel.
- Intended use: a small local educational prototype for visual apparatus detection.
- Limitations: performance may vary with lighting, camera angle, occlusion, and apparatus appearance. It does not recognize chemicals, understand procedures, or infer reaction outcomes.
- Training dataset: [Annotated Chemical Apparatus Image Dataset](https://data.mendeley.com/datasets/8p2hvgdvpn/1), DOI 10.17632/8p2hvgdvpn.1, CC BY 4.0. The dataset is not bundled in this repository.
