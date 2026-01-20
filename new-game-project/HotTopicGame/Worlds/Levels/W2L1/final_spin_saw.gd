extends AnimatedSprite2D

signal final_spike_active

@export var move_distance: Vector2 = Vector2(-850, 0)
@export var move_speed: float = 400

var player: CharacterBody2D
var moving: bool = false
var start_position: Vector2
var target_position: Vector2
var final_spike_trigger: Area2D
var has_emitted_signal: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	start_position = position
	target_position = start_position
	
	setup_connections()
func setup_connections():
	# Find the trigger
	final_spike_trigger = get_node("../TriggerFinal")  
	
	if final_spike_trigger:
		
		# Connect to the correct signal
		if final_spike_trigger.has_signal("trigger_final_spike"):
			final_spike_trigger.connect("trigger_final_spike", start_moving)
			print("FinalSpike: Connected to trigger successfully")
		else:
			print("FinalSpike: Signal 'trigger_final_spike' not found on trigger")
	else:
		print("MoveGround: Trigger not found")
	
	# Connect to player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		if player.has_signal("player_died"):
			player.connect("player_died", _reset_block)
			print("MoveGround: Connected to player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if moving:
		move_spike(delta)
	
func start_moving():
	if not has_emitted_signal:
		print("MoveSpike: Starting movement!")
		moving = true
		target_position = start_position + move_distance
		emit_signal("final_spike_active")
		has_emitted_signal = true

func move_spike(delta):
	var step = move_speed * delta
	position = position.move_toward(target_position, step)
	if position.distance_to(target_position) < step:
		position = target_position
		moving = false

func _reset_block():
	position = start_position
	moving = false
	has_emitted_signal = false
