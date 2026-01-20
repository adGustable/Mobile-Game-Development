extends Node2D

@onready var scene_tree = get_tree()
@onready var joystick_button = $CanvasLayer/VBoxContainer/UseJoystick

func _ready():
	# Connect the checkbox signal
	joystick_button.toggled.connect(_on_use_joystick_toggled)
	
	# Set checkbox to reflect current setting
	joystick_button.button_pressed = Event.use_joystick

func _on_return_pressed() -> void:
	$FileManager.save_settings_to_file()
	scene_tree.change_scene_to_file("res://HotTopicGame/Menu/Main/MainMenu.tscn")


func _on_use_joystick_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Event.use_joystick = true  # Joystick enabled
		print("Joystick enabled")
	else:
		Event.use_joystick = false  # Joystick disabled
		print("Joystick disabled")
