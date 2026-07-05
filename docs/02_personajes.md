# Gemelos Divinos

Escena base común: `CharacterBase.tscn` (`CharacterBody2D`) + FSM por nodos. Componentes compartidos: HealthComponent (calaveras), SerenityComponent (luz), BloodCircleComponent (postura), HurtboxComponent.

## Hunahpú — Rango y Luz
- Arma: Cerbatana Mística, balines de barro con luz, apuntado 360°.
- Costo: `-15.0` Serenidad por disparo (bloque fijo).
- Aura base de luz más amplia que Ixbalanqué.
- Especial: **Destello de Resplandor** — ilumina la habitación completa y ciega enemigos.

## Ixbalanqué — Melee y Agilidad
- Armas: cuchillos y hachas de obsidiana.
- Especial: **Paso del Jaguar** — dash con 12 frames de invulnerabilidad (i-frames).
- Golpe físico exitoso tras dash: `+2.0` Serenidad (incentiva agresión a corta distancia con poca luz).

## Estados FSM mínimos (nodos State)
`IdleState`, `MoveState`, `JumpState`, `FallState`, `DashState` (i-frames), `AttackState`, `MeditatingState` (DidacticManager), `PanicState`, `StunnedState` (ver [[04_balance_gamefeel]]), `DeadState`.

Todo valor de balance (daño, costos, duración de dash) vive en Resources, no en scripts.
