extends Node2D  # This is your Button or parent node

@onready var area_2d: Area2D = $Area2D
@onready var spike_floor: Node2D = $"../SpikeFloor"
@onready var spike_timer: Timer = $"../SpikeTimer"

@export var move_up_distance: float = 30
@export var move_speed: float = 150

var start_position: Vector2
var target_position: Vector2
var moving_up: bool = false
var moving_down: bool = false

func _ready():
	# Connect to button signal
	area_2d.connect("buttonPushed", Callable(self, "activate_spike_floor"))

	# Track spike start position
	start_position = spike_floor.position
	target_position = start_position - Vector2(0, move_up_distance)

	# Connect to player death
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))
	else:
		push_warning("Player node not found in group 'player'")

	# Connect the timer's timeout signal
	spike_timer.connect("timeout", Callable(self, "_on_reset_timer_timeout"))

func _physics_process(delta):
	if moving_up:
		spike_floor.position = spike_floor.position.move_toward(target_position, move_speed * delta)
		if spike_floor.position.distance_to(target_position) < 1:
			moving_up = false

	if moving_down:
		spike_floor.position = spike_floor.position.move_toward(start_position, move_speed * delta)
		if spike_floor.position.distance_to(start_position) < 1:
			moving_down = false

func activate_spike_floor():
	moving_up = true
	moving_down = false  # Cancel any downward motion

func _on_player_died():
	spike_timer.start(0.3)

func _on_reset_timer_timeout():
	moving_down = true
