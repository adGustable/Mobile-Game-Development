extends StaticBody2D

var angle = PI
var radius = 150.0
var speed = 1.0
var center_position = Vector2(-103, 1) # Set the center of the circular motion

func _process(delta):
	angle += speed * delta 
	position.x = center_position.x + radius * cos(angle)
	position.y = center_position.y + radius * sin(angle)
