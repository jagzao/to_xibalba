# Fase 2 — Hoja de Especificaciones de Media: Ixbalanqué (media contract)

Destinatario: Diseñador Artístico + agentes. El visual debe gritar agresividad a corta distancia, agilidad felina y misticismo lunar (contraste radical con Hunahpú).

## 1. Concept art de selección: El Guerrero Jaguar
- Complexión robusta y fibrosa. Capa de piel de jaguar de Xibalbá con manchas que brillan plateado/púrpura neón en la oscuridad. Ojos con fulgor blanco lunar constante. Dos cuchillos ceremoniales de obsidiana negra pulida.
- Atmósfera: postura felina baja y acechante, frente a arco de piedra con glifos mayas que reaccionan a la luz de la luna.
- Destino: `game/assets/sprites/players/ixbalanque/concept/ixbalanque_selection_art.png`

## 2. Assets de producción (contrato para el enjambre)
Exportar PNG con **transparencia real** (canal alpha, sin ajedrezado horneado, sin textos) a `game/assets/sprites/players/ixbalanque/`:

### ixbalanque_spritesheet.png — grid 64×64 px
| Anim | Descripción |
|---|---|
| Idle | agachado, balanceo suave de depredador listo para saltar |
| Run | carrera en cuatro puntos (estilo jaguar) |
| Paso del Jaguar (Dash) | 12 frames: cuerpo estirado y difuminado, estela de partículas plateadas translúcidas (= los i-frames) |

### ixbalanque_vfx_slash.png — grid 96×96 px
- Ráfagas curvas púrpura neón (cortes de obsidiana). Se instancia en cada ataque melee.
- Destino: `game/assets/sprites/vfx/`

### ixbalanque_death_states.png — grid variado
- **Desmembramiento**: al perder todas las calaveras, los cuchillos se rompen en mil pedazos que se clavan en su propio torso mientras cae de rodillas.
- **Decapitación felina**: cabeza (con tocado de jaguar) cercenada limpiamente, rastro procedural de sangre oscura.

## Regla de calidad para TODOS los spritesheets (aplica retroactivo a Hunahpú)
1. Canal alpha real (fondo transparente, nunca ajedrezado pintado).
2. Grid fijo por archivo (64×64 personajes, 96×96 VFX), sin títulos ni etiquetas dentro de la imagen.
3. Un archivo por categoría: `<personaje>_spritesheet.png`, `<personaje>_death_states.png`, `<personaje>_vfx_*.png`.
Los sheets que no cumplan van a `<personaje>/reference/` como concepto, no a producción.
