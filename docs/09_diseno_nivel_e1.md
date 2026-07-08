# Diseño de Niveles — Guía + Blueprint Escenario 1

## 1. Principio rector: la atmósfera ES la mecánica
En Xibalbá la opresión no se pinta, se juega: la luz del jugador (Serenidad) es su
única ventana al mundo. Todo el nivel se diseña alrededor de eso:
- **Oscuridad = niebla de guerra.** El jugador nunca ve la sala completa; ve un
  círculo que se encoge cuando peor está. El pánico del jugador real y el del
  personaje son el mismo sistema.
- Regla: cada sala debe ser legible en memoria tras UNA pasada iluminada. El
  terror viene de recordar dónde estaba el peligro que ya no ves.

## 2. ¿Túnel o capas? — Ambas, en niveles distintos
- **MACRO (el mapa): grafo de salas, nunca túnel.** Hollow Knight no es lineal:
  es una red de salas con bifurcaciones, loops y atajos que regresan. El jugador
  avanza, se pierde un poco, reconoce un lugar, y ese "¡aquí ya estuve!" es la
  recompensa.
- **MICRO (cada sala): capas visuales y de gameplay** (ver §5).
- E1 = ~9 salas conectadas, 2 sub-zonas, 3 loops. No corredor con puertas.

## 3. Reglas de dificultad (estilo HK, dificultad justa)
1. **Enseñar → Retar → Combinar.** Cada mecánica aparece primero sin castigo
   (tronco que se hunde sobre suelo seguro), luego con castigo (sobre cañas),
   luego combinada (tronco + murciélagos + serenidad drenándose x2).
2. **Checkpoint ANTES del reto, no después.** La estela va a la entrada de la
   secuencia difícil. Morir repite el reto, no la caminata.
3. **Atajo al superar:** cada tramo duro abre un regreso corto (plataforma que
   cae, puerta de un solo lado). El backtracking nunca repite el desafío.
4. **Secretos fuera de la luz:** fragmentos de códice y altares opcionales a
   1-2 pantallas de la ruta, marcados con un brillo tenue en el borde del aura.
5. **El castigo escala con la avaricia, no con el azar:** rutas opcionales
   drenan más serenidad; la ruta principal es dura pero estable.

## 4. Métricas de salto (derivadas de MovementStatsResource — NO inventar)
speed=150, jump_velocity=-320, gravity=980, coyote=0.1s, buffer=0.1s:
| Métrica | Valor | En tiles de 16 px |
|---|---|---|
| Altura de salto | 52 px | ~3 tiles |
| Tiempo en aire | 0.65 s | — |
| Gap horizontal máximo | ~98 px (+15 px coyote) | 6 tiles |
| Personaje (colisión 16×32) | — | 1 ancho × 2 alto |

**Tile = 16 px.** Reglas duras:
- Gap estándar: 4 tiles. Gap "desafío": 5. Gap 6 SOLO en retos opcionales.
- Altura escalable estándar: 2 tiles. Reto: 3 (exige salto completo).
- Techo mínimo en zona de salto: 5 tiles (no cortar el arco).
- Pasillo mínimo: 3 tiles de alto, 2 si es a propósito claustrofóbico (max 6 tiles de largo).

## 5. Anatomía de una sala (capas en Godot)
```
Room (Node2D)
├── ParallaxBackground
│   ├── Capa -3: negrura + siluetas lejanas (estalactitas, Camazotz cruzando)
│   ├── Capa -2: columnas/raíces (scroll 0.4)
│   └── Capa -1: rocas cercanas (scroll 0.7)
├── TileMapLayer "Deco"      (sin colisión: musgo, glifos, huesos)
├── TileMapLayer "Suelo"     (colisión; physics layer 1)
├── TileMapLayer "Hazards"   (cañas/sangre; el Area2D real lo ponen HazardFloor/SerenityZone)
├── Entidades (SinkingPlatform, InvisiblePlatform, Checkpoint, Altar, Murcielago)
├── SerenityZone (multiplicador de la sala: 1.0 en E1.1, 2.0 en E1.2)
├── CanvasModulate (Color(0.04,0.04,0.06) — el mundo casi negro; solo la luz revela)
├── GPUParticles2D ambiente (esporas/polvo/goteo, densidad por sub-zona)
└── CameraLimits (Area2D que fija límites de Camera2D al entrar)
```

## 6. Checklist de atmósfera opresiva (por sala)
- [ ] CanvasModulate oscuro; NADA de luz ambiental gratis.
- [ ] Al menos 1 elemento de escala aplastante (techo alto que la luz no alcanza,
      pozo cuyo fondo no se ve).
- [ ] Sonido: dron grave continuo + 2-3 one-shots posicionales (goteo, aleteo
      lejano, crujido). SILENCIO total 2-3 s antes del peligro nuevo.
- [ ] Paleta por sub-zona: E1.1 grises fríos + verde bilis (cañas); E1.2 rojos
      profundos + amarillo pus. El neón rojo de los glifos sube de intensidad
      conforme te acercas al final.
- [ ] Foreshadow: silueta del peligro futuro en parallax (murciélagos antes de
      la sala de murciélagos; una guadaña gigante tallada antes de la Corte).
- [ ] Nunca enseñar el monstruo completo antes del primer susto.

## 7. Blueprint E1 — Los Ríos de Pesadilla (grafo)
```
                    [S0 Boca del Inframundo]
                       ▼ (descenso vertical, tutorial de caída)
   atajo C ┌────── [S1 Vestíbulo] ── altar Xolo + estela
           │           ▼
           │        [S2 Río de Cañas I]  troncos sobre suelo seguro → sobre cañas
           │           ▼
           │        [S3 Pozo de los Ecos] vertical ↑, 1er murciélago, estela
           │           ▼                   secreto: fragmento códice (izq, gap 6)
           │        [S4 Cañas II]  troncos + murciélagos combinados
           │           ▼
           └────── [S5 Umbral] estela + altar Colibrí — abre atajo C a S1
                       ▼  (SerenityZone 2.0 desde aquí — decay x2)
                    [S6 Río de Sangre I] plataformas invisibles (luz alta)
                       ▼        dilema: gastar cerbatana vs conservar luz
                    [S7 Galería Ciega] tramo largo sin altar, enjambre
                       ▼        si serenidad <30% las plataformas mueren
                    [S8 Huida] persecución de enjambre hacia la salida
                       ▼
                    [Salida → Corte de los 12 Señores]
```
- S2/S4/S6/S7 son las "pruebas"; S1/S3/S5 respiran (altar, estela, lore).
- Loop de riesgo: S3 secreto exige volver con serenidad alta (revisita con luz).
- S8 = clímax coreografiado: correr>pelear, enseña que huir es válido (Casa
  de los Murciélagos lo exigirá).

## 8. Orden de construcción (para el enjambre)
1. Greybox S1-S2 con tiles placeholder → validar métricas §4 con tests de salto.
2. Entidades existentes coloca­das (SinkingPlatform, HazardFloor, Checkpoint, Altar).
3. Cámara + límites por sala.
4. Arte: tileset rios + parallax (assets pendientes: fondos parallax).
5. Audio ambiente + partículas.
6. Playtest de serenidad: cronometrar ruta S5→S8 sin altar (debe ser posible con ~60% del tanque).
