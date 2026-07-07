extends CanvasLayer
## HUD reactivo: solo escucha EventBus. Sin referencias al jugador.

const SKULL_FILLED := "☠"
const SKULL_EMPTY := "○"

@onready var skulls_container: Label = %Skulls
@onready var blood_bar: ProgressBar = %BloodBar
@onready var serenity_bar: ProgressBar = %SerenityBar
@onready var codex_panel: PanelContainer = %CodexPanel
@onready var codex_title: Label = %CodexTitle
@onready var codex_author: Label = %CodexAuthor
@onready var codex_content: Label = %CodexContent


func _ready() -> void:
	EventBus.serenity_changed.connect(_on_serenity_changed)
	EventBus.blood_circle_changed.connect(_on_blood_circle_changed)
	EventBus.skulls_changed.connect(_on_skulls_changed)
	EventBus.panic_entered.connect(_on_panic_entered)
	EventBus.panic_exited.connect(_on_panic_exited)
	EventBus.artifact_read_started.connect(_on_artifact_read_started)
	EventBus.artifact_read_completed.connect(_on_artifact_read_completed)
	codex_panel.hide()


func _on_serenity_changed(current: float, max_value: float) -> void:
	serenity_bar.max_value = max_value
	serenity_bar.value = current


func _on_blood_circle_changed(current: float, max_value: float) -> void:
	blood_bar.max_value = max_value
	blood_bar.value = current


func _on_skulls_changed(current: int, max_value: int) -> void:
	var text := ""
	for i: int in range(max_value):
		text += SKULL_FILLED if i < current else SKULL_EMPTY
		text += " "
	skulls_container.text = text.strip_edges()


func _on_panic_entered() -> void:
	serenity_bar.modulate = Color(1.0, 0.2, 0.2)


func _on_panic_exited() -> void:
	serenity_bar.modulate = Color.WHITE


func _on_artifact_read_started(id: String, text: String) -> void:
	codex_title.text = id
	codex_author.text = ""
	codex_content.text = text
	codex_panel.show()


func _on_artifact_read_completed() -> void:
	codex_panel.hide()
