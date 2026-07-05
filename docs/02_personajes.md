# Gemelos Divinos (Módulo 2 — Arquitectura Component-Based)

Escena base común: `CharacterBase.tscn`. Prohibido duplicar lógica de movimiento entre gemelos.

```
[CharacterBase (CharacterBody2D)]  -> colisiones físicas generales y gravedad
   ├── [FiniteStateMachine (Node)] -> estados de movimiento
   │      ├── IdleState / MoveState / JumpState / FallState / DashState
   │      ├── AttackState / MeditatingState / PanicState / StunnedState / DeadState
   ├── [CombatComponent (Node)]    -> cooldown de ataques e invulnerabilidad
   └── [CharacterVisuals (Node2D)] -> sprites + PointLight2D
```

## Contrato de Habilidades (inyección de dependencias)
`res://game/src/core/player_ability.gd` — clase virtual, sin escena:

```gdscript
extends Node
class_name PlayerAbility

@export var serenity_cost: float = 0.0

func execute_ability(player: CharacterBody2D, event_bus: Node) -> void:
	pass
```

Cada gemelo implementa la suya. Valores de balance en Resources, nunca hardcodeados.

## HunahpuAbility — Cerbatana Mística y Destello
- Al presionar habilidad: verificar `current_serenity >= 15.0`; si pasa, descontar vía EventBus.
- **Estado de apuntado** (estado FSM secundario): gemelo plantado en el suelo; stick derecho/cursor rota vector 360°. Al soltar, instancia `ProjectileLight` en línea recta con shader de quemadura solar contra entes de Xibalbá.
- Especial: **Destello de Resplandor** — ilumina habitación completa y ciega enemigos.
- Aura de luz base más amplia que Ixbalanqué.

## IxbalanqueAbility — Paso del Jaguar y Combo Melee
- Sin proyectiles. Dash direccional terrestre o aéreo.
- Primeros **12 frames** del dash: `hurtbox.monitoring = false` (i-frames).
- **Absorción**: golpe de corte de obsidiana dentro de los **2 s** posteriores a un dash exitoso → señal a EventBus → `+2.0` Serenidad por impacto.
- Extra sigilo: **Manto de Jaguar** (camuflaje en sombras, ver Casa de los Jaguares en [[03_niveles]]).

## Diseño visual (gemelos_concept)
### Hunahpú — El Resplandor del Sol
- Piel bronceada, pintura corporal geométrica amarillo/blanco místico. Tocado de plumas de guacamaya con brillo tenue en oscuridad. Silueta esbelta (agilidad, rango).
- Cerbatana ceremonial de madera oscura con incrustaciones de concha nácar que destellan **cian** cuando la Serenidad está al máximo.

### Ixbalanqué — La Fuerza de la Luna
- Piel de jaguar real sobre los hombros; ojos con fulgor plateado/lunar constante. Musculatura marcada. Pintura corporal negro obsidiana y rojo sangre.
- Par de hachas cortas / navajas anchas de obsidiana pulida que reflejan la poca luz.
