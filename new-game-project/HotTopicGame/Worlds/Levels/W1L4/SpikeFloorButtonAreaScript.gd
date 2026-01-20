extends Area2D

signal buttonPushed

@onready var spike_floor_green_button: AnimatedSprite2D = $".."

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		spike_floor_green_button.play("press")  # Correct way to play animation
		await spike_floor_green_button.animation_finished
		spike_floor_green_button.play_backwards("press")
		emit_signal("buttonPushed")
