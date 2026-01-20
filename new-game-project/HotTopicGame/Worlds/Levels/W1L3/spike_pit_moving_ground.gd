extends Node2D

signal block_started_moving  # Declare the signal


@export var move_distance: Vector2 = Vector2(126, 0)  # Move right by 100
@export var move_speed: float = 800  # Speed of the ground's movement

var player = Node
var moving: bool = false
var start_position: Vector2
var target_position: Vector2
var moving_ground_trigger: Node
var has_emitted_signal: bool = false  # Ensure we emit the signal only once

# Assuming you're instancing the player scene somewhere in your main scene


func _ready():
	await get_tree().process_frame  # Wait one frame to ensure all nodes are added
	
	start_position = position  # Store the original position
	target_position = start_position  # Initially, target position is the start position
	moving_ground_trigger = get_node("/root/Level3/SpikePitMovingGroundTrigger")
	
	#A giant headache that hurts my soul. but confirms the correct connection.
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D and node.has_signal("player_died"):
			player = node
			break

	if player:
		player.connect("player_died", Callable(self, "_reset_block"))
	else:
		push_warning("Player node not found in group 'player'")

	
	if moving_ground_trigger:
		moving_ground_trigger.connect("player_triggered_moving_ground", Callable(self, "start_moving"))

	set_physics_process(true)  # Enable physics processing for fixed timestep updates

func _physics_process(delta):
	# Only move if the moving flag is set
	if moving:
		move_block(delta)


func start_moving():
	if not has_emitted_signal:  # Only emit the signal the first time
		#print("MovingGround: Starting movement!")  # Debugging
		moving = true
		target_position = start_position + move_distance  # Set the target position
		emit_signal("block_started_moving")  # Emit signal to notify other objects
		has_emitted_signal = true  # Prevent further emissions

# Move the block directly towards the target position
func move_block(delta):
	var step = move_speed * delta
	position = position.move_toward(target_position, step)

	if position.distance_to(target_position) < step:
		position = target_position
		moving = false

func _reset_block():
	position = start_position  # Move the block back to the original position
	moving = false  # Stop the movement
	has_emitted_signal = false  # Reset the signal flag so it can emit again
