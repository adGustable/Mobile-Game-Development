extends Node2D

signal block_started_moving  # Declare the signal

@export var move_up_distance: float = -150
@export var move_right_distance: float = 1060
@export var move_speed: float = 310

var player = Node
var moving: bool = false
var start_position: Vector2
var intermediate_position: Vector2
var final_position: Vector2
var moving_wall_trigger: Node2D
var has_emitted_signal: bool = false

enum MovementPhase { NONE, UP, RIGHT }
var phase := MovementPhase.NONE


func _ready():
	await get_tree().process_frame

	start_position = position
	intermediate_position = start_position + Vector2(0, move_up_distance)
	final_position = intermediate_position + Vector2(move_right_distance, 0)
	
	moving_wall_trigger = get_node("/root/Level3/MovingWallTrigger")
	
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D and node.has_signal("player_died"):
			player = node
			break

	if player:
		player.connect("player_died", Callable(self, "_reset_block"))
	else:
		push_warning("Player node not found in group 'player'")

	if moving_wall_trigger:
		moving_wall_trigger.connect("player_triggered_moving_wall", Callable(self, "start_moving"))

	set_physics_process(true)


func _physics_process(delta):
	if moving:
		move_block(delta)


func start_moving():
	if not has_emitted_signal:
		moving = true
		phase = MovementPhase.UP
		emit_signal("block_started_moving")
		has_emitted_signal = true


func move_block(delta):
	var step = move_speed * delta

	match phase:
		MovementPhase.UP:
			position = position.move_toward(intermediate_position, step)
			if position.distance_to(intermediate_position) < step:
				position = intermediate_position
				phase = MovementPhase.RIGHT

		MovementPhase.RIGHT:
			position = position.move_toward(final_position, step)
			if position.distance_to(final_position) < step:
				position = final_position
				phase = MovementPhase.NONE
				moving = false


func _reset_block():
	position = start_position
	moving = false
	has_emitted_signal = false
	phase = MovementPhase.NONE
