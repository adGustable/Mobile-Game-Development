class_name filemanager
extends Node

const SAVE_PATH = "user://samegame.data"
const SETTINGS_PATH = "user://traps_settings.data"

# Save data
func save() -> Dictionary:
	var save_dict = {
		"total_death": Event.total_death,
		"level_data": Event.level_data
	}
	return save_dict
	
# Save settings
func save_settings() -> Dictionary:
	var settings_dict = {
		"use_joystick": Event.use_joystick,
	}
	return settings_dict

func save_game() ->void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_file.store_var(call("save"))
	
func save_settings_to_file() -> void:
	var settings_file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	settings_file.store_var(call("save_settings"))
	settings_file.close()
	
func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		# Set default settings if no settings file exists
		Event.use_joystick = true
		save_settings_to_file()
		return
	
	var settings_file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var settings_data = settings_file.get_var()
	
	Event.use_joystick = settings_data["use_joystick"]
	
	settings_file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_game()
		return
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var saved_data = save_file.get_var()
	
	Event.total_death = saved_data["total_death"]
	Event.level_data = {} if saved_data["level_data"].is_empty() else saved_data["level_data"]
