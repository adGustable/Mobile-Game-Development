extends Area2D

signal pushed

@onready var move_door_button: AnimatedSprite2D = $".."

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		move_door_button.play("press")  # Correct way to play animation
		await move_door_button.animation_finished
		move_door_button.play_backwards("press")
		emit_signal("pushed")
		
