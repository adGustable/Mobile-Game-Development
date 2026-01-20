extends Control

@onready var death_container: HBoxContainer = $CanvasLayer/Hud/DeathContainer
@onready var pause_screen: ColorRect = $PauseScreen
@onready var level_complete: TextureRect = $LevelComplete
@onready var scene_tree = get_tree()
@onready var label: Label = $CanvasLayer/Hud/DeathContainer/TextureRect/Label

var death_count: int = 0

func _ready():
	death_count = 0
	Event.level_complete.connect(_on_level_completed)
	Event.connect("deaths", _on_death_collected)
		

func _on_death_collected(value) -> void:
	death_count += value
	label.text = "%d" % death_count


func display_level_complete() -> void:
	if not Event.curr_level < Event.level_data.size():
		%NextLevelButton.visible = false
	scene_tree.call_group("ButtonContainer", "hide")
	pause_screen.visible = false
	%PauseButton.visible = false
	death_container.visible = false
	level_complete.visible = true
	

func _on_level_completed() :
	%DeathLabel.text = str(death_count)
	Event.set_total_death(death_count)
	var next_level = Event.curr_level + 1
	if Event.level_data.has(next_level):
		Event.level_data[next_level] = false
	%FileManager.save_game()
	display_level_complete()

func goto_home() -> void:
	#%fader.fade_screen(true, 0, func(): 
	scene_tree.change_scene_to_file("res://HotTopicGame/Menu/Main/MainMenu.tscn")
	#)

func goto_level_select() -> void:
	#%fader.fade_screen(true, 0, func(): 
	scene_tree.change_scene_to_file("res://HotTopicGame/Menu/LevelSelect/level_select.tscn")
	#)

func goto_next_level() -> void:
	var next_level := "res://HotTopicGame/Worlds/Levels/Level" + str(Event.curr_level + 1) + ".tscn"
	if  	ResourceLoader.exists(next_level):
		Event.curr_level += 1
		#%fader.fade_screen(true, 1.0, func(): 
		scene_tree.change_scene_to_file(next_level)
		#)
	else:
		scene_tree.change_scene_to_file("res://HotTopicGame/Menu/LevelSelect/level_select.tscn")


func restart_game() -> void:
	death_count = 0
	set_game_paused(false)
	scene_tree.reload_current_scene()
	
func set_game_paused(value: bool) -> void:
	scene_tree.paused = value
	pause_screen.visible = value
	scene_tree.call_group("buttonContainer", "hide" if value else "show")
	%PauseButton.visible = not value
	$CanvasLayer/Hud/DeathContainer.visible = not value
	

func exit_game():
	%DeathLabel.text = str(death_count)
	Event.set_total_death(death_count)
	$FileManager.save_game()
	death_count = 0
	set_game_paused(false)
	#Fader code didnt work
	#%fader.fade_screen(true, 0, func(): 
	scene_tree.change_scene_to_file("res://HotTopicGame/Menu/Main/MainMenu.tscn")
	#)

func _on_resume_button_down() -> void:
	set_game_paused(false)


func pause_game() -> void:
	set_game_paused(true)
