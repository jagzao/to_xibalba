# Spec: Spritesheets y media de Ixbalanqué (spritesheets)

Fuente de diseño: `docs/08_ixbalanque_media.md` y `docs/07_sistema_muerte.md` (integración gore).

## 1. Descripción
Cerrar el loop de media para Ixbalanqué: validar que el `SpriteAnimator` pueda cargar frames de carpetas, reproducir animaciones según estados de FSM, y manejar spritesheets de muerte/gore opcionalmente.

## 2. Componentes
- **SpriteAnimator** (ya existe `game/src/components/sprite_animator.gd`): carga frames desde `frames_root/{anim}/NN.png`, mapea estados FSM → animación, flip por facing.
- **GoreDataResource** (nuevo, `game/src/core/gore_data_resource.gd`): datos de pivotes y texturas para desmembramiento.
- **BossFatalityScene** (nuevo, `game/src/effects/boss_fatality_scene.gd`): escena base para ejecuciones de jefes.

## 3. Criterios de aceptación
1. `SpriteAnimator` construye animaciones de carpetas con nombres válidos.
2. Cambio de estado FSM reproduce la animación mapeada.
3. Estados sin animación propia fallback a `idle` o `panic` según gemelo.
4. `flip_h` sigue a `_character.facing`.
5. `GoreDataResource` tiene pivotes exportados.
6. `BossFatalityScene` puede reproducir una fatality por tipo de jefe.

## 4. Casos borde
- `frames_root` vacío o inexistente → SpriteFrames vacío, no crash.
- Carpeta de animación sin PNGs → animación existe pero vacía.
- Estado no mapeado → `idle`.
