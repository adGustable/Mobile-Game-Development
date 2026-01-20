extends Node

signal deaths(value)
signal level_complete

var curr_level: int = 1
var total_death: int = 0
var level_data: Dictionary = {}
var use_joystick: bool = 0

func set_total_death(value) -> void:
	total_death += value
	emit_signal("deaths", total_death)
