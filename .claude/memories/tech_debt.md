# Tech Debt — Xibalbá

## Sesión 2026-07-09: MVP El Descenso + dirección de arte v2
- **ARTE v2: NO pixel art** — alta calidad ilustrada, Filter Linear en imports. Docs 00+10 actualizados; sheets pixel actuales = solo referencia de forma.
- Docs: `docs/10_mvp_descenso.md` — MVP 3 salas (Caída Libre, Grietas del Escondite, Ascenso Vertical) + cápsulas A1-A5 + tabla de balance. Premisa: gemelos SIN armas.
- MovementStatsResource: +fall_damage_height(512), fall_impact_damage(40), wall_slide_speed(60), wall_jump_push(200).
- CharacterBase: `fall_distance` acumulada → aterrizaje duro = blood damage + Stunned (`_on_landed`); `wall_direction` (get_wall_normal; los tests la setean directo); `external_force` (viento); `nearby_crevice`.
- Estados nuevos en FSM (CharacterBase.tscn): WallSlideState (clamp caída, resetea fall_distance, wall jump opuesto + facing volteado; entra desde Fall con input hacia pared), HidingState (luz OFF = inaudible; interact entra/sale desde Idle/Move).
- Entidades nuevas: CrumblingPlatform (pisada → tiembla → colapsa 0.4s → respawn 3s), AcidPool (Serenidad→0 + drenado sangre/s afectado por pánico x1.5), WindCurrent (external_force), CreviceSpot. Enemigo: BlindStalker (ciego, `can_hear()` = no-Hiding && velocity>umbral; embestida quita calavera).
- Tests: 193/193 (12 nuevos test_mvp_descenso.gd). Gotcha propio: el drenado de ácido lleva x1.5 de pánico — la expectativa del test debe usar PANIC_DAMAGE_MULTIPLIER.
- Deuda: greybox de las 3 salas del Descenso pendiente (Escenario1.tscn existente es de los ríos); crouch (techo bajo Sala 2) no existe; murciélago modo pasivo-patrulla pendiente; eco posicional del stalker pendiente de AudioManager.

## Sesión 2026-07-08: batches A/B/C

### Deuda técnica deliberada (ponytail)
- `AudioManager` usa placeholders WAV generados; reemplazar por assets finales.
- `Escenario1.tscn` es greybox con ColorRects; falta tileset real y parallax.
- `BossBase.take_damage` lee `damage` del área atacante con `get("damage")`; formalizar contrato de hitbox.
- `BallGameManager` fase 2/3 son placeholders vacíos; implementar ilusiones/proyectiles falsos.
- `SlashVFX` y `BossFatalityScene` usan frames/procedural placeholders.
- `HunahpuAbility.trigger_flash` e `IxbalanqueAbility.trigger_cloak` siguen siendo stubs.
- `LevelExit` solo emite `respawn_started`; necesita transición de escena real.

### Tests con warnings no bloqueantes
- `test_ranged_attack.gd`: 2 unfreed children (preexistente).
- `test_separar_gemelos.gd`: 1 orphan en `test_ixbalanque_absorption_post_dash` (preexistente).

### Próximos pasos sugeridos
- Integrar tileset rios en Escenario1.
- Implementar habilidades gemelas completas.
- Añadir menú principal / selección de personaje.
- Crear escenas E3 (casas) y E2 (CouncilRoom lleno).
