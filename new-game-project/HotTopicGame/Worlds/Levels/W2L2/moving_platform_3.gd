extends AnimatableBody2D

var start_y
var time = 0.0
var delay = 7.0

func _ready():
	start_y = position.y
	sync_to_physics = true

func _physics_process(delta):
	time += delta * 2
	
	if time > delay:
		var new_y = start_y + sin(time - delay) * 150
		position.y = new_y
