# sprite-cleaner (process_image)

Limpia spritesheets generados por IA: convierte el checkerboard gris "falso" en transparencia real y borra textos/cabeceras. Salida lista para Godot.

## Instalar
```bash
pip install -r requirements.txt
```

## Ejecutar
```bash
python clean_sprites.py --input ./sprites_input --output ./sprites_output
# con escala 2x y mascaras de debug:
python clean_sprites.py --input ./sprites_input --output ./sprites_output --scale 2 --debug true
```

## Parámetros
| Flag | Default | Efecto |
|---|---|---|
| `--scale` | 1 | 2 = exporta además `_clean_2x.png` (nearest-neighbor) |
| `--remove-text` | true | borra cabeceras/letras oscuras |
| `--text-top-ratio` | 0.18 | franja superior donde el borrado de texto es más agresivo |
| `--alpha-threshold` | 14 | tolerancia de gris del checker (sube si queda fondo, baja si borra sprite) |
| `--debug` | false | exporta `_bg_mask`, `_text_mask`, `_alpha_preview` (magenta = transparente) |

## Lógica (corta)
1. Detecta los 1-2 grises dominantes de píxeles casi-neutros → tonos del checker.
2. Máscara de fondo = píxeles cercanos a esos tonos **y conectados al borde de la imagen** (así no borra grises internos del sprite, ej. armaduras).
3. Fondo → alpha 0; blur 1 px en el alpha para matar halos duros.
4. Texto = componentes opacos oscuros, anchos y de poca altura (o cualquier bloque oscuro en la franja superior) → alpha 0.
5. Guarda `nombre_clean.png` (+ `_2x` opcional).

## Revisar manualmente cuando…
- El checker queda **encerrado** entre extremidades sin conexión al borde (no se borra: es intencional, revisa con `--debug`).
- Brillos/humos grises muy parecidos al checker y pegados al borde → pueden borrarse; baja `--alpha-threshold`.
- Texto **encima** del sprite o sprites muy oscuros y horizontales (charcos de sangre) → puede borrarlos; usa `--remove-text false` y limpia a mano.
- Halos: el glow amarillo mezclado con gris deja franja sucia de 1-2 px; aceptable en juego, o retocar en Aseprite.

## Importar en Godot
- PNG con transparencia, arrastrar a `game/assets/...`.
- En Import: **Compression = Lossless**, **Filter = Nearest** (pixel art), **Mipmaps = Off**. Reimportar.
- Usar `AnimatedSprite2D` (SpriteFrames recortando regiones) o `Sprite2D` + `AtlasTexture` por frame.
