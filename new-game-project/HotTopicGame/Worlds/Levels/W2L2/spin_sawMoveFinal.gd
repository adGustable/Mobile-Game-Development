extends AnimatedSprite2D

signal saw_started_moving

@export var move_distance: Vector2 = Vector2(0, -25)
@export var move_speed: float = 800

var player: CharacterBody2D
var moving: bool = false
var start_position: Vector2
var target_position: Vector2
var moving_saw_trigger: Area2D
var has_emitted_signal: bool = false

func _ready():
	await get_tree().process_frame
	
	start_position = position
	target_position = start_position
	
	setup_connections()

func setup_connections():
	# Find the trigger
	moving_saw_trigger = get_node("../TriggerFinalSaw")  
	
	if moving_saw_trigger:
		
		# Connect to the correct signal
		if moving_saw_trigger.has_signal("triggered_moving_saw"):
			moving_saw_trigger.connect("triggered_moving_saw", start_moving)
			#print("MoveGround: Connected to trigger successfully")
		else:
			print("MoveSaw: Signal 'player_triggered_moving_ground' not found on trigger")
	else:
		print("MoveSaw: Trigger not found")
	
	# Connect to player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		if player.has_signal("player_died"):
			player.connect("player_died", _reset_block)
			print("MoveSaw: Connected to player")

func _physics_process(delta):
	if moving:
		move_block(delta)

func start_moving():
	if not has_emitted_signal:
		print("MoveSaw Starting movement!")
		moving = true
		target_position = start_position + move_distance
		emit_signal("saw_started_moving")
		has_emitted_signal = true

func move_block(delta):
	var step = move_speed * delta
	position = position.move_toward(target_position, step)
	if position.distance_to(target_position) < step:
		position = target_position
		moving = false

func _reset_block():
	position = start_position
	moving = false
	has_emitted_signal = false
