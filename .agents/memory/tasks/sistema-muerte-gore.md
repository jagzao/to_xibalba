# Spec: Sistema de muerte/gore y partículas (sistema-muerte-gore)

Fuente de diseño: `docs/06_sistema_muerte_gore.md`.

## 1. Descripción
Capa de feedback visceral: sangre al daño, efectos de muerte según tipo de daño, respawn/checkpoint y pantalla de Game Over.

## 2. Componentes
- **GoreEffect** (nuevo, `game/src/effects/gore_effect.gd`): `Node2D`. Según `damage_type` emite partículas y/o shakes de cámara.
  - `damage_type`: `BLOOD`, `SKULL`, `FALL`, `FIRE`, `DARKNESS`.
  - Configura `CPUParticles2D` o `GPUParticles2D` según tipo.
- **DeathManager** (nuevo, `game/src/core/death_manager.gd`): autoload o nodo de escena. Recibe `player_died`, espera animación, respawnea o muestra Game Over.
- **DeathScreen** (nuevo, `game/src/ui/DeathScreen.gd`): Control con fade a negro y texto.

## 3. Flujo
```
[Daño mortal / data.current_skulls == 0] → EventBus.player_died.emit(origin)
→ DeathManager: reproducir GoreEffect → fade negro → respawn_position si skulls>0
→ si skulls==0: Game Over
```

## 4. Balance
- Duración fade: 0.5 s.
- Duración gore: 1.0 s.
- Máximas partículas por tipo: 32.
- Skulls restantes > 0 → respawn inmediato.
- Skulls == 0 → Game Over, escena `res://scenes/GameOver.tscn` (stub).

## 5. Señales EventBus
- `player_died(origin: String)`: nuevo.

## 6. Criterios de aceptación
1. `GoreEffect.play("BLOOD")` instancia partículas de color rojo.
2. `GoreEffect.play("SKULL")` instancia partículas de color blanco/hueso.
3. `GoreEffect.play("FALL")` no instancia partículas pero hace shake.
4. `DeathManager` al recibir `player_died` reduce calavera si no es Game Over.
5. Con calaveras restantes respawnea en `data.respawn_position`.
6. Sin calaveras muestra `DeathScreen` Game Over.
7. HUD no se rompe durante respawn.

## 7. Casos borde
- Múltiples muertes rápidas: no doble respawn.
- `respawn_position` en `Vector2.ZERO` si no se tocó checkpoint.
- Daño mientras ya en Game Over: ignorado.
