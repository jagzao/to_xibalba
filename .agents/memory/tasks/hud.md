# Spec: HUD (hud)

Fuente: `docs/01_arquitectura.md` (EventBus, inversión de dependencias UI). Asunciones aprobadas 2026-07-07 sin refinar.

## 1. Descripción
HUD reactivo: calaveras de vida, círculo de sangre, barra de serenidad y panel de códice. Solo escucha EventBus — prohibido `get_node("/root/Player")` o refs a nodos de lógica. Placeholders nativos de Godot; el arte re-viste después sin tocar lógica.

## 2. Componentes
- **HUD.tscn** (nuevo, `game/src/ui/HUD.tscn`): CanvasLayer raíz + `hud.gd`.
  - `Skulls` (HBoxContainer con 3 TextureRect/Label placeholders llenos/vacíos)
  - `BloodBar` (ProgressBar horizontal, v1; radial con arte)
  - `SerenityBar` (ProgressBar; color normal ↔ rojo crítico en pánico)
  - `CodexPanel` (PanelContainer centrado, oculto por default: Title/Author/Content Labels)
- **hud.gd** (nuevo, `game/src/ui/hud.gd`): en `_ready()` se suscribe a EventBus. Sin estado propio más allá de lo visual.
- Fuera de scope: barra equilibrio Luz/Oscuridad (E4), shakes/aberración (E2), arte final.

## 3. Flujo
```
serenity_changed(c,m)    → SerenityBar.max_value=m, value=c
blood_circle_changed(c,m)→ BloodBar idem
skulls_changed(c,m)      → renderizar c llenas de m
panic_entered            → SerenityBar modulate rojo crítico
panic_exited             → modulate normal
artifact_read_started(id,text) → CodexPanel.show() + poblar texto
artifact_read_completed  → CodexPanel.hide()
```
HUD arranca vacío; se llena con la primera emisión (no lee estado inicial).

## 4. Balance
Sin valores de gameplay. Color pánico: rojo (`Color(1, 0.2, 0.2)`) — constante visual en hud.gd, no es balance.

## 5. Señales EventBus
Usadas: las 7 de arriba. Nuevas: ninguna.

## 6. Criterios de aceptación (asserts GUT)
1. Instanciar HUD.tscn no crashea y CodexPanel está oculto.
2. `EventBus.serenity_changed.emit(50,100)` → SerenityBar.value==50, max_value==100.
3. `blood_circle_changed.emit(30,100)` → BloodBar.value==30.
4. `skulls_changed.emit(1,3)` → 1 llena, 2 vacías (estado visual verificable).
5. `panic_entered` → modulate de SerenityBar ≠ blanco; `panic_exited` → vuelve a blanco.
6. `artifact_read_started("X","poema")` → CodexPanel visible con el texto; `artifact_read_completed` → oculto.
7. El script hud.gd NO contiene referencias a CharacterBase/Player (verificable por diseño; assert: HUD funciona sin ningún jugador en escena).

## 7. Casos borde
- Señales emitidas antes de que el HUD exista → se pierde la emisión; el siguiente cambio lo corrige (aceptado v1).
- max_skulls > 3 futuro: renderizado data-driven desde el parámetro max de skulls_changed, no hardcodear 3 hijos.
- Dos lecturas de códice seguidas: segunda started repuebla el panel.
