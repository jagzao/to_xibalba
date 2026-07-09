# MVP — El Descenso (primera sección de E1)

**Cambio de dirección de arte (2026-07-09):** ya NO pixel art. Gráficos de alta
calidad: ilustración refinada, texturas detalladas, iluminación rica. En Godot:
Import → Filter **Linear** (no Nearest), mipmaps permitidos en fondos. Los
sheets existentes sirven de referencia de forma/palette, se re-generarán en
calidad alta con el mismo pipeline (chroma green → clean → slice).

Premisa narrativa: los gemelos caen a Xibalbá **sin sus armas** (cuchillos y
cerbatana se recuperan después). El MVP es survival de plataformeo puro.

## Sala 1 — El Descenso en Caída Libre ("La Prueba de la Gravedad")
Caída al abismo sin suelo firme; solo plataformas traicioneras.
- **Daño por caída:** caída vertical continua > `fall_damage_height`
  (equivalente visual a 4 bloques de 128 px = 512 px) → al impactar superficie
  sólida: daño de impacto al Círculo de Sangre + Stagger severo (StunnedState).
- **Plataformas desmoronables:** al pisarlas tiemblan y se destruyen en
  **0.4 s** (`crumble_delay`); reaparecen tras `respawn_delay` (3 s) para
  permitir reintentos. Obligan a zig-zag continuo calculado en el aire.
- **Murciélagos pasivos:** colgados de paredes o en trayectorias horizontales
  predecibles. NO persiguen: el peligro es chocarlos cayendo sin control.

### Las 5 Cápsulas de Caída (estructura vertical de Sala 1)
| Cápsula | Nombre | Reto |
|---|---|---|
| A1 | La Brecha de la Superficie | caída libre limpia, aprender control de aire; termina en bifurcación de 2 mini-túneles |
| A2 | El Zig-Zag de las Rocas | espacio estrecho, desmoronables escalonadas; quedarse quieto = caer al vacío |
| A3 | La Fosa del Cenote | centro bloqueado por estalactitas gigantes → pegarse a los extremos; abajo, estanque ácido |
| A4 | Las Ventiscas del Pánico | corrientes de viento empujan entre pinchos hacia túneles laterales |
| A5 | El Umbral del Fondo | velocidad máxima acumulada: encadenar wall-slides para frenar antes del suelo de Sala 2 |

### Peligros del Descenso (transversales)
- **Cenotes de Pus y Sangre (aguas mortales):** caer dentro → Serenidad a 0
  instantáneo + drenado de Círculo de Sangre por segundo; salir YA (saltar a
  pared rugosa) o morir.
- **Cornisas traicioneras:** salientes para "respirar" que se desmoronan a los
  0.4 s — mantener la inercia.
- **Corrientes de viento subterráneo:** chorros desde grietas laterales.
  Algunos empujan horizontal (ayudan a alcanzar túneles); otros succionan
  hacia abajo (aceleran la caída → garantizan daño de impacto si no reaccionas).
- **Nidos de murciélagos colgantes:** caer cerca despierta a uno que cruza tu
  trayectoria horizontal de escape.

## Sala 2 — Las Grietas del Escondite ("El Acecho en la Penumbra")
Techo aplastante, avance agachado, SIN armas → survival horror táctico.
- **Ocultamiento en grietas:** hendiduras oscuras en el fondo de piedra (capa
  intermedia del parallax). `interact` frente a una → el personaje se pega a
  la pared trasera: silueta oscurecida y **aura de luz apagada** (HidingState).
- **La amenaza imbatible:** patrulla un enemigo terrestre **ciego con oído
  hiperdesarrollado** (BlindStalker). No se puede matar.
- **Bucle:** escuchar el eco → avanzar rápido entre las desmoronables que
  queden → deslizarse a una grieta justo antes de que pase. Quieto fuera de
  grieta = imposible esquivar (el pasillo no da espacio).

## Sala 3 — El Ascenso Vertical ("Parkour e Inercia")
La cueva se abre hacia arriba en una brecha colosal.
- **Wall slide / wall jump:** saltar hacia una pared de roca volcánica rugosa
  → deslizamiento lento (`wall_slide_speed`); impulso en dirección opuesta
  para encadenar saltos pared-a-pared (`wall_jump_push`).
- **Reto combinado:** rebotar en pared firme → caer con precisión en
  desmoronable → saltar de inmediato antes de que caiga → alcanzar saliente.
- **Murciélagos de presión:** en los ángulos muertos de los rebotes. Si te
  estancas en una pared, uno baja en picada y te tira al fondo (foso de agua
  o suelo seguro: repites el ascenso, no mueres instantáneo).

## Balance (→ MovementStatsResource salvo indicado)
| Valor | Default |
|---|---|
| fall_damage_height | 512.0 px |
| fall_impact_damage | 40.0 (Círculo de Sangre) + StunnedState |
| crumble_delay / respawn_delay | 0.4 s / 3.0 s (export en CrumblingPlatform) |
| wall_slide_speed | 60.0 px/s |
| wall_jump_push | 200.0 px/s horizontal (vertical = jump_velocity) |
| acid: drenado de sangre | 25.0/s (export en AcidPool) + Serenidad → 0 al entrar |
| viento | Vector2 export por WindCurrent (aceleración px/s²) |
| oído del BlindStalker | radio export; detecta si NO estás en Hiding y te mueves |

## Entidades nuevas
CrumblingPlatform, AcidPool, WindCurrent, CreviceSpot, BlindStalker,
HidingState + WallSlideState (FSM). Murciélago pasivo = MurcielagoPeriferia
en modo patrulla (sin seek).

Tras Sala 3 → continúa el blueprint de ríos ([[09_diseno_nivel_e1]] S1-S8).
