extends Node
## Bus de eventos global (Autoload). UI y entorno solo se suscriben aquí.

signal serenity_changed(current: float, max_value: float)
signal blood_circle_changed(current: float, max_value: float)
signal skulls_changed(current: int, max_value: int)
signal panic_entered()
signal panic_exited()
signal artifact_read_started(id: String, text: String)
signal artifact_read_completed()
signal balance_changed(value: float)
signal player_died(origin: String)
signal respawn_started()
signal game_over()
