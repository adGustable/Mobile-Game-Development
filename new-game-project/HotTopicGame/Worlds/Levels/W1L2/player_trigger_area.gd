extends Area2D

signal player_triggered  # Signal to notify other objects

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):  # Ensure only the player triggers it
		emit_signal("player_triggered")  # Send the signal
