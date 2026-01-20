extends Area2D

signal player_triggered_moving_ground  # Signal to notify other objects

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	#print("Trigger detected player!")  # Debugging
	if body.is_in_group("player"):  # Ensure only the player triggers it
		#print("Emitting signal: player_triggered_moving_ground")  # Debugging
		emit_signal("player_triggered_moving_ground")  # Send the signal
