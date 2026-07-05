# Escenario 4 — El Juego de Pelota Final (Módulo 6)

Clímax: no es hack'n'slash. Enfrentamiento deportivo/místico vs Hun-Camé y Vucub-Camé, fiel al desenlace del Popol Vuh. Recontextualiza destreza + plataformas + gestión de Serenidad.

```
       [Marcador de Destino: Luz vs Oscuridad]
                     ┌─────────┐
                     ▼         ▼
[Hunahpú / Ixbalanqué] ◄──(Pelota de Navajas)──► [Hun-Camé / Vucub-Camé]
                     ▲         ▲
                     └─────────┘
        [Cancha de Xibalbá: Trampas de Suelo Activas]
```

## 6.1 BallGameManager (subsistema; altera inputs de combate temporalmente)

### Pelota Mística (`KineticBall2D`)
- `RigidBody2D`, rebote elástico perfecto (bounce = 1.0, fricción 0).
- Estados según último golpeador:
  - **Cargada de Luz** (golpe del gemelo: cerbatana Hunahpú / corte obsidiana Ixbalanqué): viaja hacia los dioses con mayor velocidad.
  - **Cargada de Oscuridad/Navajas** (devuelta por los Señores): rozar al jugador drena **25% del Círculo de Sangre**.

### Desvío (Deflection/Parry)
- Prohibido agarrar la pelota; solo redirigir con timing de ataque.
- **Perfect Parry** (último frame posible): velocidad de pelota ×2 y `+20.0` Serenidad.

### Marcador del Universo
- Sin puntos numéricos: barra de equilibrio Luz↔Oscuridad en UI (vía EventBus, señal nueva p.ej. `balance_changed(value: float)`).
- Pelota toca pared de fondo de los dioses → barra hacia Luz.
- Pelota toca fondo del jugador → barra hacia Oscuridad.
- Barra al extremo Oscuridad → **−1 Calavera instantánea**.

## 6.2 Fases

### Fase 1 — El Cráneo de Siete Guacamaya
- Pelota estándar; suelo de cancha activa trampas de cañas espinosas intermitentes.
- Exige saltar, dash y golpear la pelota en el aire.

### Fase 2 — La Decapitación Simulada
- Entorno totalmente oscuro; pelota invisible salvo dentro del radio de luz/Serenidad del jugador.
- Los dioses lanzan proyectiles falsos (ilusiones) para quebrar la Serenidad.
- Guía por sonido posicional; identificar el impacto verdadero.
