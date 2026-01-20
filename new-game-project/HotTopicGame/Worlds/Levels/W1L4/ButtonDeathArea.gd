extends Area2D

@onready var red_death_button: AnimatedSprite2D = get_parent()  # One level up

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		red_death_button.play("press")  # Correct way to play animation
		await red_death_button.animation_finished
		body.die()  # Replace with your actual death logic
		red_death_button.play_backwards("press")
