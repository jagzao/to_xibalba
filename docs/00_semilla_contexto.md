# XIBALBÁ — El Camino del Miedo (Semilla de Contexto)

Metroidvania 2D en Godot 4 basado en el Popol Vuh: los Gemelos Divinos (Hunahpú e Ixbalanqué) descienden a Xibalbá. Gameplay = resistencia psicológica (Serenidad/Luz) + destreza. Precisión histórica maya obligatoria en textos y nombres.

## Índice de diseño (inmutable para agentes)
- [[01_arquitectura]] — PlayerDataResource, EventBus, DidacticManager, fórmulas
- [[02_personajes]] — Gemelos, FSM, habilidades
- [[03_niveles]] — Escenarios 1–3 y jefes
- [[04_balance_gamefeel]] — coyote time, buffering, stun, pánico
- [[05_protocolo_ia]] — harness Python, TDD, multi-LLM
- [[06_juego_pelota]] — Escenario 4: Juego de Pelota final (BallGameManager)
- [[07_sistema_muerte]] — Gore pack, muertes procedimentales, fatalities de jefes
- [[08_ixbalanque_media]] — contrato de media de Ixbalanqué + regla de calidad de spritesheets
- [[09_diseno_nivel_e1]] — guía de diseño de niveles + blueprint del Escenario 1
- [[10_mvp_descenso]] — MVP: El Descenso (3 salas, cápsulas A1-A5, wall jump, sigilo)

## Dirección de arte (v2, 2026-07-09)
Alta calidad ilustrada: texturas refinadas, iluminación rica. NO pixel art.
Import en Godot: Filter Linear. Los sheets pixel existentes = referencia de forma.

## Reglas de código
Ver `.claude/CLAUDE.md`. Resumen: composición > herencia, UI solo vía EventBus, tipado estático, FSM con nodos State, datos en Resources, test GUT por cada componente.
