extends AnimatedSprite2D

@export var move_speed: float = 300  # Movement speed

var start_position: Vector2
var right_position: Vector2
var left_position: Vector2
var current_target: Vector2
var moving: bool = false
var trigger: Node
var player: Node
var area: Area2D
var has_triggered: bool = false
var movement_state: String = "waiting"  # "waiting", "moving_right", "moving_left"

func _ready():
	start_position = position
	right_position = start_position + Vector2(800, 0)  # Move right 800 pixels
	left_position = right_position - Vector2(600, 0)   # Move left 600 pixels from right
	
	# Find the trigger
	trigger = get_node("/root/Level6/TriggerHiddenSpike")
	if trigger:
		if trigger.has_signal("trigger_hidden_spike"):
			trigger.connect("trigger_hidden_spike", Callable(self, "_on_trigger"))
		else:
			print("Trigger doesn't have 'trigger_hidden_spike' signal")
	else:
		print("Trigger not found")
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("player_died"):
		player.connect("player_died", Callable(self, "_reset_saw"))
		print("Connected to player")
	
	# Find the Area2D child
	area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("No Area2D found - add one as a child!")

func _on_trigger():
	if not has_triggered:
		has_triggered = true
		start_back_and_forth_movement()

func start_back_and_forth_movement():
	movement_state = "moving_right"
	current_target = right_position
	moving = true

func _physics_process(delta):
	if moving:
		position = position.move_toward(current_target, move_speed * delta)
		# Check if we've reached the target
		if position.distance_to(current_target) < 1.0:
			position = current_target
			
			if movement_state == "moving_right":
				# Reached right position, now move left
				movement_state = "moving_left"
				current_target = left_position				
			elif movement_state == "moving_left":
				# Reached left position, now move right again
				movement_state = "moving_right"
				current_target = right_position

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.die()

func _reset_saw():
	position = start_position
	moving = false
	has_triggered = false
	movement_state = "waiting"
	current_target = Vector2.ZERO
