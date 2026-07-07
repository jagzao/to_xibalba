extends CanvasLayer
class_name HUD
## Solo escucha EventBus. Prohibido referenciar nodos de lógica del jugador.

const PANIC_TINT: Color = Color(1.0, 0.2, 0.2)

@onready var skulls_box: HBoxContainer = $Root/TopLeft/Skulls
@onready var blood_bar: ProgressBar = $Root/TopLeft/BloodBar
@onready var serenity_bar: ProgressBar = $Root/TopLeft/SerenityBar
@onready var codex_panel: PanelContainer = $Root/CodexPanel
@onready var codex_text: Label = $Root/CodexPanel/CodexText


func _ready() -> void:
	var bus: Node = get_node("/root/EventBus")
	bus.serenity_changed.connect(_on_serenity_changed)
	bus.blood_circle_changed.connect(_on_blood_circle_changed)
	bus.skulls_changed.connect(_on_skulls_changed)
	bus.panic_entered.connect(_on_panic_entered)
	bus.panic_exited.connect(_on_panic_exited)
	bus.artifact_read_started.connect(_on_artifact_read_started)
	bus.artifact_read_completed.connect(_on_artifact_read_completed)
	codex_panel.hide()


func _on_serenity_changed(current: float, max_value: float) -> void:
	serenity_bar.max_value = max_value
	serenity_bar.value = current


func _on_blood_circle_changed(current: float, max_value: float) -> void:
	blood_bar.max_value = max_value
	blood_bar.value = current


func _on_skulls_changed(current: int, max_value: int) -> void:
	for child: Node in skulls_box.get_children():
		skulls_box.remove_child(child)
		child.free()
	for i: int in max_value:
		var skull := Label.new()
		skull.text = "☠"
		skull.modulate.a = 1.0 if i < current else 0.25
		skulls_box.add_child(skull)


func _on_panic_entered() -> void:
	serenity_bar.modulate = PANIC_TINT


func _on_panic_exited() -> void:
	serenity_bar.modulate = Color.WHITE


func _on_artifact_read_started(_id: String, text: String) -> void:
	codex_text.text = text
	codex_panel.show()


func _on_artifact_read_completed() -> void:
	codex_panel.hide()
