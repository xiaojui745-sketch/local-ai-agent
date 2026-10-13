"""Local HTTP UI and inference service for the chemistry apparatus YOLO model."""
from __future__ import annotations

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from io import BytesIO
from pathlib import Path

from PIL import Image, UnidentifiedImageError
from ultralytics import YOLO


ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = ROOT / "runs" / "apparatus_v1" / "weights" / "best.pt"
PAGE_PATH = Path(__file__).resolve().parent / "index.html"
MAX_IMAGE_BYTES = 15 * 1024 * 1024
HOST = os.environ.get("CHEM_SIM_HOST", "127.0.0.1")
PORT = int(os.environ.get("CHEM_SIM_PORT", "8765"))

if not MODEL_PATH.is_file():
    raise SystemExit(f"Trained model not found: {MODEL_PATH}")

print(f"Loading model from {MODEL_PATH}", flush=True)
model = YOLO(str(MODEL_PATH))
print(f"Model ready on CUDA device 0; opening http://localhost:{PORT}", flush=True)


class Handler(BaseHTTPRequestHandler):
    server_version = "ChemistrySim/0.1"

    def _send(self, status: int, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _json(self, status: int, payload: dict) -> None:
        self._send(status, json.dumps(payload, ensure_ascii=False).encode("utf-8"), "application/json; charset=utf-8")

    def do_GET(self) -> None:  # noqa: N802
        if self.path in ("/", "/index.html"):
            self._send(200, PAGE_PATH.read_bytes(), "text/html; charset=utf-8")
        elif self.path == "/health":
            self._json(200, {"ok": True, "model": str(MODEL_PATH), "device": "cuda:0"})
        else:
            self._json(404, {"error": "Not found"})

    def do_POST(self) -> None:  # noqa: N802
        if self.path != "/predict":
            self._json(404, {"error": "Not found"})
            return
        try:
            size = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self._json(400, {"error": "Invalid content length"})
            return
        if size <= 0 or size > MAX_IMAGE_BYTES:
            self._json(413, {"error": "图片必须大于 0 且不超过 15 MB。"})
            return
        try:
            image = Image.open(BytesIO(self.rfile.read(size))).convert("RGB")
        except (UnidentifiedImageError, OSError):
            self._json(400, {"error": "无法读取图片，请选择 JPG、PNG 或 WebP 图片。"})
            return

        width, height = image.size
        try:
            result = model.predict(source=image, imgsz=640, device=0, verbose=False)[0]
            boxes = []
            if result.boxes is not None:
                for box in result.boxes:
                    cls_id = int(box.cls.item())
                    x1, y1, x2, y2 = [round(float(v), 2) for v in box.xyxy[0].tolist()]
                    boxes.append({
                        "class_id": cls_id,
                        "name": result.names[cls_id],
                        "confidence": round(float(box.conf.item()), 4),
                        "xyxy": [x1, y1, x2, y2],
                    })
            self._json(200, {"width": width, "height": height, "count": len(boxes), "detections": boxes})
        except Exception as exc:  # return a useful local error without killing the server
            self._json(500, {"error": f"模型推理失败：{type(exc).__name__}: {exc}"})

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"[{self.log_date_time_string()}] {fmt % args}", flush=True)


try:
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
except KeyboardInterrupt:
    print("\nChemistry simulator stopped.", flush=True)
