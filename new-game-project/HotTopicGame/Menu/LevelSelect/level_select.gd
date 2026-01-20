extends Control

@onready var scene_tree = get_tree()
@onready var deathLabel = $DeathTexture/Label

func _ready():
	connect_level_selected_to_level_box()
	%FileManager.load_game()

	if Event.level_data.is_empty():
		setup_level_box()
	else:
		load_level_box_data()

	deathLabel.text = str(Event.total_death)


func setup_level_box() -> void:
	for box in %LevelGrid.get_children():
		var index = box.get_index() + 1
		box.level_num = index

		var is_unlocked = (index == 1)  # Only level 1 starts unlocked
		box.locked = not is_unlocked
		Event.level_data[index] = not is_unlocked  # true = locked

func load_level_box_data() -> void:
	for box in %LevelGrid.get_children():
		var index = box.get_index() + 1
		box.level_num = index

		# Default to locked except for level 1
		var is_locked = Event.level_data.get(index, index != 1)
		box.locked = is_locked
		Event.level_data[index] = is_locked  # Ensure key exists for all levels

func change_to_scene(level_num: int) -> void:
	Event.curr_level = level_num
	scene_tree.change_scene_to_file("res://HotTopicGame/Worlds/Levels/Level" + str(level_num) + ".tscn")

func connect_level_selected_to_level_box() -> void:
	for box in %LevelGrid.get_children():
		box.connect("level_selected", change_to_scene)

func _on_home_button_down() -> void:
	scene_tree.change_scene_to_file("res://HotTopicGame/Menu/Main/MainMenu.tscn")
