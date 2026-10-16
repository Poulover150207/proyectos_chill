extends Node2D

@onready var interactive_area: Area2D = $InteractiveArea

var player_nearby: bool = false


func _ready() -> void:
	interactive_area.body_entered.connect(_on_interactive_area_body_entered)
	interactive_area.body_exited.connect(_on_interactive_area_body_exited)


func _process(_delta: float) -> void:
	# Solo se puede interactuar con la tecla E ("interact") y estando cerca.
	if player_nearby and Input.is_action_just_pressed("interact"):
		interact()


func _on_interactive_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_interactive_area_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_nearby = false

	
	var dialogue_ui = _get_dialogue_ui()
	if dialogue_ui != null and dialogue_ui.is_open:
		dialogue_ui.close_dialogue()


func _get_dialogue_ui():
	if not is_inside_tree() or get_tree().current_scene == null:
		return null
	return get_tree().current_scene.get_node_or_null("DialogueUI")


func interact() -> void:
	var dialogue_ui = _get_dialogue_ui()
	if dialogue_ui == null:
		push_warning("NPC: no se encontró el nodo DialogueUI en la escena.")
		return

	
	if dialogue_ui.is_open:
		dialogue_ui.next_dialogue()
		return

	match QuestManager.quest_state:
		QuestManager.QuestState.NOT_STARTED:
			dialogue_ui.show_dialogue(
				"Dr. Han Solo",
				[
					"Guardian, i need your help!",
					"the enemies has dispared the magic crystals around the city",
					"recover them quickly and bring them to me before they ate lost"
				]
			)
			QuestManager.start_quest()
		QuestManager.QuestState.ACTIVE:
			dialogue_ui.show_dialogue(
				"Dr. Han Solo",
				[
					"We´re still missing some of the crystals",
					"You only found %d of %d" % [
						QuestManager.collected_crystals,
						QuestManager.required_crystals
					]
				]
			)
		QuestManager.QuestState.READY_TO_DELIVER:
			dialogue_ui.show_dialogue(
				"Dr. Han Solo",
				[
					"Excelent!, You find all crystals on time",
					"We can use the portal now"
				]
			)
			QuestManager.complete_quest()
		QuestManager.QuestState.COMPLETED:
			dialogue_ui.show_dialogue(
				"Dr. Han Solo",
				[
					"Thanks for the extra hand in this task!",
					"The portal is ready to use"
				]
			)
