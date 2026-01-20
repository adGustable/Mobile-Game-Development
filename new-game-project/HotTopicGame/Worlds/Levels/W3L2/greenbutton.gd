extends Area2D
@onready var green_button: AnimatedSprite2D = $".."
signal btn_pressed  # Define a custom signal

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		green_button.play("press") 
		emit_signal("btn_pressed")
