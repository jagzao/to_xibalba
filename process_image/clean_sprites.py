"""Limpia spritesheets generados por IA para Godot.

- Detecta el checkerboard gris "falso" y lo convierte en alpha real.
- Quita textos/cabeceras (letras oscuras, anchas y bajas) sin tocar sprites.
- Opcional: exporta version 2x nearest-neighbor.

Uso:
    python clean_sprites.py --input ./sprites_input --output ./sprites_output
"""
import argparse
import sys
import traceback
from pathlib import Path

import cv2
import numpy as np

EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}


def str2bool(value: str) -> bool:
    return str(value).lower() in ("1", "true", "yes", "y")


def load_bgr(path: Path) -> np.ndarray:
    # np.fromfile + imdecode: soporta rutas con acentos en Windows
    data = np.fromfile(str(path), dtype=np.uint8)
    img = cv2.imdecode(data, cv2.IMREAD_UNCHANGED)
    if img is None:
        raise ValueError("no se pudo decodificar la imagen")
    if img.ndim == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    if img.shape[2] == 4:
        # el alpha existente es falso (checker quemado): se ignora
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
    return img


def save_png(path: Path, img: np.ndarray) -> None:
    ok, buf = cv2.imencode(".png", img)
    if not ok:
        raise ValueError("no se pudo codificar PNG")
    buf.tofile(str(path))


def find_checker_tones(img: np.ndarray) -> list[int]:
    """Devuelve las luminancias de los 1-2 grises dominantes del checkerboard."""
    channels = img.astype(int)
    spread = channels.max(axis=2) - channels.min(axis=2)
    grayish = spread < 14
    if not grayish.any():
        return []
    lum = channels.mean(axis=2)[grayish].astype(int) // 4 * 4
    vals, counts = np.unique(lum, return_counts=True)
    min_count = img.shape[0] * img.shape[1] * 0.02
    tones: list[int] = []
    for idx in np.argsort(-counts):
        if counts[idx] < min_count or len(tones) == 2:
            break
        v = int(vals[idx])
        if all(abs(v - t) > 10 for t in tones):
            tones.append(v)
    return tones


def is_chroma_green(img: np.ndarray) -> bool:
    h, w = img.shape[:2]
    corners = [img[2, 2], img[2, w - 3], img[h - 3, 2], img[h - 3, w - 3]]
    green = 0
    for c in corners:
        b, g, r = int(c[0]), int(c[1]), int(c[2])
        if g > 140 and g > r * 1.6 and g > b * 1.6:
            green += 1
    return green >= 2


def green_mask(img: np.ndarray) -> np.ndarray:
    b = img[:, :, 0].astype(int)
    g = img[:, :, 1].astype(int)
    r = img[:, :, 2].astype(int)
    return (g > 140) & (g > r * 1.6) & (g > b * 1.6)


def background_mask(img: np.ndarray, tones: list[int], tol: int) -> np.ndarray:
    """Mascara del fondo: pixeles grises cercanos a los tonos del checker
    y conectados al borde de la imagen (no borra grises internos del sprite)."""
    channels = img.astype(int)
    spread = channels.max(axis=2) - channels.min(axis=2)
    lum = channels.mean(axis=2)
    # rango completo entre ambos tonos: incluye los pixeles de transicion
    # entre mosaicos, si no cada cuadrito queda desconectado del borde
    low = min(tones) - tol
    high = max(tones) + tol
    candidate = (spread < 20) & (lum >= low) & (lum <= high)
    if not candidate.any():
        return candidate
    _, labels = cv2.connectedComponents(candidate.astype(np.uint8), connectivity=4)
    edges = np.concatenate([labels[0, :], labels[-1, :], labels[:, 0], labels[:, -1]])
    border_ids = np.unique(edges)
    border_ids = border_ids[border_ids != 0]
    return np.isin(labels, border_ids)


def text_mask(img: np.ndarray, alpha: np.ndarray, top_ratio: float) -> np.ndarray:
    """Componentes opacos que parecen texto: oscuros, anchos y de poca altura."""
    height, width = alpha.shape
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    dark = (hsv[:, :, 2] < 90) & (alpha > 0)
    # agrupar letras de una misma linea
    joined = cv2.dilate(dark.astype(np.uint8), np.ones((3, 15), np.uint8))
    num, labels, stats, _ = cv2.connectedComponentsWithStats(joined, connectivity=8)
    mask = np.zeros_like(dark)
    for i in range(1, num):
        x, y, w, h, area = stats[i]
        if h == 0 or area < 40:
            continue
        aspect = w / h
        h_frac = h / height
        comp = labels == i
        dark_ratio = dark[comp].mean()
        in_top = (y + h) <= height * top_ratio
        looks_like_line = aspect >= 3.0 and h_frac <= 0.05 and dark_ratio >= 0.3
        looks_like_header = in_top and aspect >= 1.5 and dark_ratio >= 0.25
        if looks_like_line or looks_like_header:
            mask |= comp
    return mask


def despeckle(img: np.ndarray, alpha: np.ndarray, max_area: int = 150) -> np.ndarray:
    """Borra componentes opacos chicos y grises (restos de checker).
    Las particulas de color (sangre, chispas, magia) se conservan."""
    channels = img.astype(int)
    spread = channels.max(axis=2) - channels.min(axis=2)
    num, labels, stats, _ = cv2.connectedComponentsWithStats(
        (alpha > 0).astype(np.uint8), connectivity=8
    )
    for i in range(1, num):
        if stats[i, cv2.CC_STAT_AREA] > max_area:
            continue
        comp = labels == i
        if spread[comp].mean() < 22:
            alpha[comp] = 0
    return alpha


def process_image(
    path: Path,
    out_dir: Path,
    scale: int,
    remove_text: bool,
    top_ratio: float,
    tol: int,
    debug: bool,
) -> str:
    img = load_bgr(path)
    if is_chroma_green(img):
        bg = green_mask(img)
        mode = "chroma green"
    else:
        tones = find_checker_tones(img)
        if not tones:
            return "SKIP (sin checkerboard gris ni chroma green)"
        bg = background_mask(img, tones, tol)
        mode = f"checker {tones}"
    alpha = np.where(bg, 0, 255).astype(np.uint8)

    txt = np.zeros_like(bg)
    if remove_text:
        txt = text_mask(img, alpha, top_ratio)
        alpha[txt] = 0

    alpha = despeckle(img, alpha)

    # suavizar borde 1px para evitar halo gris duro
    alpha = cv2.GaussianBlur(alpha, (3, 3), 0)

    result = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)
    result[:, :, 3] = alpha

    stem = path.stem
    save_png(out_dir / f"{stem}_clean.png", result)
    if scale == 2:
        big = cv2.resize(result, None, fx=2, fy=2, interpolation=cv2.INTER_NEAREST)
        save_png(out_dir / f"{stem}_clean_2x.png", big)

    if debug:
        save_png(out_dir / f"{stem}_bg_mask.png", (bg * 255).astype(np.uint8))
        save_png(out_dir / f"{stem}_text_mask.png", (txt * 255).astype(np.uint8))
        preview = result.copy()
        preview[alpha == 0] = (255, 0, 255, 255)  # magenta = transparente
        save_png(out_dir / f"{stem}_alpha_preview.png", preview)

    return f"OK ({mode}, texto borrado: {int(txt.sum())} px)"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, help="carpeta de origen")
    parser.add_argument("--output", required=True, help="carpeta de destino")
    parser.add_argument("--scale", type=int, choices=(1, 2), default=1)
    parser.add_argument("--remove-text", type=str2bool, default=True)
    parser.add_argument("--text-top-ratio", type=float, default=0.18)
    parser.add_argument("--alpha-threshold", type=int, default=14)
    parser.add_argument("--debug", type=str2bool, default=False)
    args = parser.parse_args()

    in_dir = Path(args.input)
    out_dir = Path(args.output)
    if not in_dir.is_dir():
        print(f"ERROR: no existe la carpeta {in_dir}")
        return 1
    out_dir.mkdir(parents=True, exist_ok=True)

    files = sorted(p for p in in_dir.iterdir() if p.suffix.lower() in EXTENSIONS)
    if not files:
        print(f"ERROR: sin imagenes en {in_dir}")
        return 1

    failures = 0
    for f in files:
        try:
            status = process_image(
                f, out_dir, args.scale, args.remove_text,
                args.text_top_ratio, args.alpha_threshold, args.debug,
            )
            print(f"[{status}] {f.name}")
        except Exception as exc:  # continuar con las demas
            failures += 1
            print(f"[ERROR] {f.name}: {exc}")
            if args.debug:
                traceback.print_exc()
    print(f"Listo: {len(files) - failures}/{len(files)} procesadas -> {out_dir}")
    return 0 if failures == 0 else 2


if __name__ == "__main__":
    sys.exit(main())
