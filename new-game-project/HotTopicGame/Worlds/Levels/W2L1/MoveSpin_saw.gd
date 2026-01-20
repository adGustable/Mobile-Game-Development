extends AnimatedSprite2D


@export var move_distance: float = 400.0  # How far to move in pixels
@export var move_duration: float = 1.5    # Time to complete one direction

var start_position: Vector2
var tween: Tween

func _ready():
	start_position = global_position
	setup_movement()

func setup_movement():
	tween = create_tween()
	tween.set_loops()  # Loop infinitely
	
	# Move right
	tween.tween_property(self, "global_position:x", 
						start_position.x + move_distance, move_duration)
	# Move back left
	tween.tween_property(self, "global_position:x", 
						start_position.x, move_duration)
