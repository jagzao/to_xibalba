"""Recorta un spritesheet limpio (alpha real) en frames individuales.

Metodo: proyeccion. Filas = bandas horizontales con contenido opaco;
frames = corridas de columnas con contenido dentro de cada banda.
Exporta PNG por frame alineado al piso en canvas uniforme por fila.

Uso:
    python slice_sheet.py --input sheet_clean.png --output out_dir \
        --rows idle,run,dash,jump_fall,panic,melee
"""
import argparse
import sys
from pathlib import Path

import cv2
import numpy as np

ALPHA_MIN = 16
ROW_NOISE = 5        # px opacos max para considerar una linea "vacia"
COL_NOISE = 10       # tolera motas residuales del checker entre frames
MIN_ROW_HEIGHT = 100  # bandas mas bajas = texto/debris
MIN_ROW_PIXELS = 50000
MIN_FRAME_WIDTH = 24
MIN_FRAME_PIXELS = 1500
MIN_GAP = 6          # separacion minima de columnas vacias entre frames
PAD = 4


def runs(profile: np.ndarray, noise: int, min_gap: int = 1) -> list[tuple[int, int]]:
    """Corridas [inicio, fin) donde profile > noise, cerrando huecos < min_gap."""
    filled = profile > noise
    out: list[list[int]] = []
    start = -1
    for i, v in enumerate(filled):
        if v and start < 0:
            start = i
        elif not v and start >= 0:
            out.append([start, i])
            start = -1
    if start >= 0:
        out.append([start, len(filled)])
    merged: list[list[int]] = []
    for r in out:
        if merged and r[0] - merged[-1][1] < min_gap:
            merged[-1][1] = r[1]
        else:
            merged.append(r)
    return [tuple(r) for r in merged]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--rows", required=True, help="nombres de fila, csv")
    args = parser.parse_args()

    data = np.fromfile(args.input, dtype=np.uint8)
    img = cv2.imdecode(data, cv2.IMREAD_UNCHANGED)
    if img is None or img.shape[2] != 4:
        sys.exit("ERROR: se requiere PNG RGBA con alpha real")
    opaque = img[:, :, 3] > ALPHA_MIN

    bands: list[tuple[int, int]] = []
    for top, bottom in runs(opaque.sum(axis=1), ROW_NOISE, MIN_GAP):
        band = opaque[top:bottom]
        if bottom - top >= MIN_ROW_HEIGHT and band.sum() >= MIN_ROW_PIXELS:
            bands.append((top, bottom))

    names = [n.strip() for n in args.rows.split(",")]
    if len(bands) != len(names):
        print(f"AVISO: {len(bands)} bandas detectadas vs {len(names)} nombres")
        names = (names + [f"row{i}" for i in range(len(bands))])[: len(bands)]

    out_root = Path(args.output)
    for name, (top, bottom) in zip(names, bands):
        band = opaque[top:bottom]
        frames: list[tuple[int, int, int, int]] = []  # x, y, w, h absolutos
        for left, right in runs(band.sum(axis=0), COL_NOISE, MIN_GAP):
            if right - left < MIN_FRAME_WIDTH:
                continue
            piece = band[:, left:right]
            if piece.sum() < MIN_FRAME_PIXELS:
                continue
            ys = np.nonzero(piece.any(axis=1))[0]
            frames.append((left, top + int(ys[0]), right - left, int(ys[-1] - ys[0] + 1)))
        if not frames:
            continue
        cell_w = max(f[2] for f in frames) + PAD * 2
        cell_h = max(f[3] for f in frames) + PAD * 2
        out_dir = out_root / name
        out_dir.mkdir(parents=True, exist_ok=True)
        for old in out_dir.glob("*.png"):
            old.unlink()
        for i, (x, y, w, h) in enumerate(frames):
            crop = img[y : y + h, x : x + w]
            cell = np.zeros((cell_h, cell_w, 4), dtype=np.uint8)
            ox = (cell_w - w) // 2
            oy = cell_h - PAD - h  # bottom-align: pies en la misma linea
            cell[oy : oy + h, ox : ox + w] = crop
            ok, buf = cv2.imencode(".png", cell)
            buf.tofile(str(out_dir / f"{i:02d}.png"))
        print(f"{name}: {len(frames)} frames de {cell_w}x{cell_h}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
