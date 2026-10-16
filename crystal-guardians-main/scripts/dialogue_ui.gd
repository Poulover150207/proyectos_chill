extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/NameLabel
@onready var dialogue_label: Label = $PanelContainer/VBoxContainer/DialogueLabel
@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueButton

var current_dialogues: Array[String] = []
var dialogue_index: int = 0
var is_open: bool = false


func _ready() -> void:
	# El panel solo se muestra cuando un NPC llama a show_dialogue().
	panel.hide()

	# Evita que Espacio (ataque) "pulse" el botón si se hizo clic en él antes.
	continue_button.focus_mode = Control.FOCUS_NONE
	continue_button.pressed.connect(next_dialogue)


# Recibe un Array "normal" a propósito: si fuera Array[String], llamarlo desde
# una variable sin tipo (como hace el NPC) da error en tiempo de ejecución.
func show_dialogue(character_name: String, dialogues: Array) -> void:
	if dialogues.is_empty():
		return

	current_dialogues.assign(dialogues)
	dialogue_index = 0
	is_open = true

	name_label.text = character_name
	# Antes faltaba esta línea: la primera frase nunca se escribía en el cuadro.
	dialogue_label.text = current_dialogues[dialogue_index]
	panel.show()


func next_dialogue() -> void:
	if not is_open:
		return

	dialogue_index += 1

	if dialogue_index >= current_dialogues.size():
		close_dialogue()
		return

	dialogue_label.text = current_dialogues[dialogue_index]


func close_dialogue() -> void:
	panel.hide()
	is_open = false
