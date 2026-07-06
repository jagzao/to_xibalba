# Módulo 7 — Sistema de Muerte Violenta y Ejecuciones (Gore Pack)

Destinatario: Agente de Animación/VFX. Cómo usar los assets de muerte para maximizar el impacto psicológico del fracaso.

## 7.1 GoreDataResource
`res://game/src/core/gore_data_resource.gd` (extends Resource, class_name GoreDataResource):

| Campo | Tipo | Uso |
|---|---|---|
| head_pivots | Array[Vector2] | puntos exactos de separación de cabeza |
| torso_pivots | Array[Vector2] | |
| limb_pivots | Array[Vector2] | |
| bone_exposed_texture | Texture2D | hueso/carne expuesta en los extremos separados |
| blood_shader_params | Dictionary | config del shader de salpicadura |

Permite desmembramiento dinámico en runtime leyendo pivotes del spritesheet.

## 7.2 Muertes procedimentales (híbrido spritesheet + shader)
- **Ácido (Corrosive Acid)**: shader de disolución que consume el sprite desde los bordes hacia adentro. Al dispararse `panic_entered` en EventBus: opacidad fluctúa y vira a verde necrótico antes de disolverse.
- **Cuchillos (Chayin-ha)**: usa spritesheet "Gore Cascade". Daño crítico → FSM fuerza `ImpaledState`; instanciar proyectiles de cuchillo en puntos aleatorios del cuerpo + partículas de sangre goteando en cascada desde las heridas.

## 7.3 Fatalities de los Señores de Xibalbá (BossFatalityScene)
Escenas de animación especiales por jefe (no spritesheet genérico):

| Jefe | Dominio | Ejecución |
|---|---|---|
| Hun-Camé | Muerte Suprema | Atrapa al jugador, zoom de cámara, decapitación con guadaña de hueso. Pantalla en rojo + frase "Un-Camé te ha juzgado" en lengua maya. |
| Ahalganá | Ictericia/Plaga | Con Círculo de Sangre en 0: inyecta veneno, piel amarilla de golpe, el cuerpo se hincha y explota (shader "Solar Overload" en amarillos/verdes). Queda solo una mancha de pus. |
| Camazotz | Murciélago Muerte | Desciende, eleva al jugador a la oscuridad. Solo silueta de murciélago gigante + sonido de desmembramiento; el cuerpo mutilado/decapitado cae en picada. |

## Assets de Hunahpú (recibidos 2026-07-06)
Carpeta: `game/assets/sprites/hunahpu/`
- `hunahpu_base.png` — Idle(6f loop), Run(8f loop), Jump&Fall(5f secuencia), Panic(4f loop) con tocado.
- `hunahpu_no_cloth_no_helm.png` — misma grilla, skin sin tocado/tela.
- `hunahpu_deaths_gore.png` — Visceral Mutilation, Crushing/Decapitation, Corrosive Acid, Solar Overload, Gore Cascade.
