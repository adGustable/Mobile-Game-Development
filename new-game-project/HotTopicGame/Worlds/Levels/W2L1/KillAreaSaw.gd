extends Area2D


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):  # Ensure your player is in the "player" group
		body.die()  # Call the player's death function
