# Escenarios y Jefes

## Escenario 1 — Los Ríos de Pesadilla (Módulo 3)
### 1.1 Río de Cañas Espinosas
- Suelo completo = `Area2D` tipo Hazard de daño continuo: tocarlo drena **1 calavera completa** y regresa al último checkpoint físico.
- Plataformas móviles: troncos flotantes que se hunden **1.5 s** después de que el jugador se posa (usar `Timer` acoplado al estado del personaje).

### 1.2 Ríos de Sangre y Pus
- Decaimiento de Serenidad duplicado: `-2.0/s`.
- Plataformas invisibles que solo reaccionan a la luz mística: **desaparecen si la Serenidad baja del 30%**.
- **Murciélagos de la Periferia** (IA Seek simple): pasivos con luz alta; si el aura se encoge por miedo, cargan directo contra el Círculo de Sangre.

## Escenario 2 — La Corte de los 12 Señores (Módulo 4)
### Puzzle del Consejo (`CouncilPuzzleRoom`)
- 12 Señores en semicírculo de piedra; la mitad son maniquíes de madera.
- Componente `DeceptiveLord (Node2D)` con enum `type { REAL, MANNEQUIN }`.
- **Revelador**: con Serenidad **> 75%**, la luz revela vetas de madera en los impostores. Con Serenidad baja: adivinar por pistas de animación — los reales parpadean/respiran levemente **cada 10 s**.
- Error (atacar/saludar incorrecto): `-50%` Serenidad inmediato (burlas de los dioses).
- **Laja Hirviente**: asiento ceremonial que parece altar de guardado. Interactuar antes de descubrir a los dos líderes reales → animación de quemadura, **Círculo de Sangre vaciado por completo** (rompe postura → StunnedState).

### Combate doble: Hun-Camé y Vucub-Camé (BossDirector)
```
               [BossDirector (Node)] -> sincronización
                │                 │
      ┌─────────┴─────────┐       └─────────┐
      ▼                   ▼                 ▼
[Hun-Camé AI]       [Vucub-Camé AI]   [Shared Blackboard]
(Fase: Agresivo)    (Fase: Soporte)   - TokenDeAtaque: Activo
                                      - PosicionJugador: Vector2
```
- **Attack Token Pattern**: portador del token = combo melee agresivo (Hun-Camé: guadañas de hueso); el otro = proyectiles de sangre a distancia que restan Serenidad (Vucub-Camé). Intercambio de token cada **15 s**.
- **Fase Extrema de Desesperación** (al morir uno): el sobreviviente absorbe el alma del otro — tamaño aumenta, radio de oscuridad del mapa se duplica de golpe (luz del jugador a la mitad), y sus ataques físicos **ignoran el Círculo de Sangre** dañando Calaveras directo. Victoria = pura destreza de esquive.

### Estética — La Plaza del Miedo (cyberpunk-prehispánico sombrío)
- Caverna colosal de piedra volcánica negra pulida; grabados mayas geométricos con neón rojo sangre tenue delimitando la arena.
- 12 tronos gigantes hacia la oscuridad; Señores con rostros de calavera estilizada, tocados de plumas negras descoloridas, túnicas de lino desgarradas.
- Fallo del puzzle: aberración cromática severa + eco de risas burlonas de baja frecuencia saturando el audio.

## Escenario 3 — Las Seis Casas del Tormento (Módulo 5)
```
                     [El Vestíbulo de Xibalbá]
            ┌───────┬───────┼───────┼───────┬───────┐
            ▼       ▼       ▼       ▼       ▼       ▼
          Casa    Casa    Casa    Casa    Casa    Casa
         Oscura   Frío  Jaguares Murciél. Cuchil. Calor
```
### Reglas comunes
- Al cruzar puerta: autosave de posición en la entrada. No se puede salir sin el **Fragmento de Códice** del final.
- Cada casa aplica modificadores de entorno globales sobre `PlayerDataResource`.

### 1. Casa Oscura (Quequma-ha) — gestión de antorcha
- Visibilidad cero: `CanvasModulate` absoluto (pantalla negra).
- **Antorcha Mística** (ítem temporal): encendida consume `-5.0` Serenidad/s. Serenidad `== 0` aquí = **muerte instantánea** (asfixia psicológica). Alternar: encender para memorizar el mapa, apagar en zonas seguras para recuperar.

### 2. Casa del Frío (Xuxulim-ha) — cronómetro de estado
- Barra de Congelación oculta: **> 4 s** sin tocar una **Piedra de Fuego** → Círculo de Sangre `-10%/s`.
- Suelo completo `physics_material.friction = 0.02` (deslizamiento; saltos entre precipicios de precisión).

### 3. Casa de los Jaguares (Balami-ha) — sigilo
- Laberinto con jaguares espectrales, IA de acecho. Contacto = **−1 Calavera directa, ignora Círculo de Sangre**.
- Estrategias: Ixbalanqué → **Manto de Jaguar** (camuflaje en sombras); Hunahpú → disparar balines a paredes opuestas para distracción sonora.

### 4. Casa de los Murciélagos (Zotzi-ha) — evasión vertical
- Ascenso vertical constante; techo custodiado por **Camazotz** (invulnerable, gigante).
- Permanecer **> 0.5 s** por encima del límite superior de la cámara → Camazotz desciende instantáneo: **−1 Calavera** (homenaje a la decapitación de Hunahpú). Fuerza juego horizontal y bajo.

### 5. Casa de los Cuchillos (Chayin-ha) — filtro de i-frames
- Estilo White Palace: sin enemigos biológicos; navajas de obsidiana autónomas en trayectorias cruzadas horizontales/verticales a velocidad extrema.
- Dash con timing incorrecto → **Círculo de Sangre vaciado instantáneo** → StunnedState en plena lluvia.

### 6. Casa del Calor (Chonay-ha) — plataformas temporales
- Suelo = lava telúrica. Plataformas de piedra volcánica porosa: nodo de colisión se destruye tras **1 s** de contacto.
- Humo denso: Serenidad `-3.0/s`. Ritmo speedrun; detenerse = morir.

## Escenario 4 — Juego de Pelota Final
Ver [[06_juego_pelota]].
