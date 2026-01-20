extends Area2D

@onready var green_button: AnimatedSprite2D = $".."


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		green_button.play("press")  # Correct way to play animation
		await green_button.animation_finished
		body.die()  # Replace with your actual death logic
		green_button.play_backwards("press")
