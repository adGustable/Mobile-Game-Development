extends Node2D

@export var move_distance: float = 280
@export var move_speed: float = 200
@export var start_delay: float = 1

var start_position: Vector2
var top_position: Vector2
var bottom_position: Vector2
var target_position: Vector2
var moving_down: bool = true

func _ready():
	set_physics_process(false)

	await get_tree().process_frame

	start_position = position
	top_position = start_position
	bottom_position = start_position + Vector2(0, move_distance)
	target_position = bottom_position

	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout

	set_physics_process(true)

func _physics_process(delta):
	var step = move_speed * delta
	position = position.move_toward(target_position, step)

	if position.distance_to(target_position) < step:
		moving_down = !moving_down
		target_position = bottom_position if moving_down else top_position
