extends StaticBody2D

@export var move_up_distance: float = 30
@export var move_speed: float = 150

var player: Node
var start_position: Vector2
var target_position: Vector2
var moving_up: bool = false

func _ready():
	start_position = position
	target_position = start_position - Vector2(0, move_up_distance)  # Up is negative y
	
	# Connect to the trigger's signals (adjust path as needed)
	var trigger = $"../HiddenSpikeTrigger"
	trigger.body_entered.connect(_on_body_entered)
	
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("player_died", Callable(self, "_reset_block"))
	else:
		push_warning("Player node not found in group 'player'")

func _physics_process(delta):
	if moving_up:
		position = position.move_toward(target_position, move_speed * delta)
		if position.distance_to(target_position) < 1:
			moving_up = false  # Reached top

func _on_body_entered(body):
	if body.is_in_group("player"):
		moving_up = true

func _reset_block():
	position = start_position  # Move the block back to the original position
