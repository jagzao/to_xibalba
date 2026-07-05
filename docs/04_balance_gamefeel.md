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
| Disparo Hunahpú | −15.0 |
| Golpe post-dash Ixbalanqué | +2.0 |
| Penalización Corte (error/Laja) | −50% |
| Lectura de altar completada | → 100% |
