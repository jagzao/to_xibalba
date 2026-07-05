# Balance y Game Feel (Filosofía de Resistencia)

Dificultad alta = diseño de nivel, nunca control torpe. Control hiper-responsivo obligatorio.

## Juice obligatorio
- **Coyote Time**: 0.1 s de margen para saltar tras dejar una plataforma.
- **Jump Buffering**: registrar salto 0.1 s antes de tocar suelo.

## Stun Lock
- Círculo de Sangre `== 0` → FSM fuerza `StunnedState`.
- Inputs deshabilitados exactamente **1.5 s**; Calaveras expuestas a daño directo.

## Pánico
- Serenidad `== 0` → `PanicState`: radio de luz `0.1`, daño recibido `× 1.5` (ver [[01_arquitectura]]).

## Economía de Serenidad
| Fuente | Δ |
|---|---|
| Decaimiento pasivo | −1.0/s |
| Ríos de Sangre y Pus | −2.0/s |
| Humo Casa del Calor | −3.0/s |
| Antorcha encendida (Casa Oscura) | −5.0/s (0 = muerte instantánea ahí) |
| Disparo Hunahpú | −15.0 |
| Golpe post-dash Ixbalanqué (ventana 2 s) | +2.0 |
| Perfect Parry (juego de pelota) | +20.0 |
| Error puzzle maniquíes | −50% |
| Lectura de altar completada | → 100% |

## Daño directo a Calaveras (ignora Círculo de Sangre)
Cañas espinosas (suelo E1.1), jaguares de Balami-ha, Camazotz (>0.5 s sobre cámara), jefe en Fase de Desesperación, extremo Oscuridad del marcador (E4).
