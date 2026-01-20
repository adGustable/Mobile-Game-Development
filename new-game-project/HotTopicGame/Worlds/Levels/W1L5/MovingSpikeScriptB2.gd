extends Node2D

@export var move_distance: float = 280
@export var move_speed: float = 200
@export var horizontal_follow_speed: float = 100
@export var start_delay: float = 2.0
@export var lunge_distance: float = 300
@export var lunge_trigger_y: float = 200
@export var lunge_height_tolerance: float = 5
@export var follow_duration: float = 6.0  # How long the block should follow the player

var player_node: Node2D = null
var start_position: Vector2
var top_position: Vector2
var bottom_position: Vector2
var target_position: Vector2
var moving_down: bool = true
var is_following: bool = false
var is_lunging: bool = false
var player_inside: bool = false
var follow_timer: Timer

var last_y_position: float
var has_lunged_this_pass: bool = false

func _ready():
	set_physics_process(false)
	await get_tree().process_frame

	start_position = position
	top_position = start_position
	bottom_position = start_position + Vector2(0, move_distance)
	target_position = bottom_position
	last_y_position = position.y

	player_node = get_tree().get_nodes_in_group("player").front()  # assumes one player

	$"../TriggerZoneB2".body_entered.connect(_on_body_entered)
	$"../TriggerZoneB2".body_exited.connect(_on_body_exited)

	# Listen for player's death signal
	if player_node.has_signal("died"):
		player_node.connect("died", Callable(self, "_on_player_died"))

	# Add timer for follow duration
	follow_timer = Timer.new()
	follow_timer.wait_time = follow_duration
	follow_timer.one_shot = true
	follow_timer.timeout.connect(_on_follow_timeout)
	add_child(follow_timer)

	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout

	set_physics_process(true)

func _physics_process(delta):
	if is_lunging or player_node == null:
		return

	if is_following:
		var target_x = player_node.global_position.x
		position.x = move_toward(position.x, target_x, horizontal_follow_speed * delta)
	else:
		position.x = move_toward(position.x, start_position.x, horizontal_follow_speed * delta)

	var step = move_speed * delta
	position.y = move_toward(position.y, target_position.y, step)

	if abs(position.y - target_position.y) < step:
		moving_down = !moving_down
		target_position = bottom_position if moving_down else top_position
		has_lunged_this_pass = false

	if moving_down and player_inside and not has_lunged_this_pass:
		if last_y_position < lunge_trigger_y and position.y >= lunge_trigger_y:
			perform_lunge()
			has_lunged_this_pass = true

	last_y_position = position.y

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true
		start_following()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false

func start_following():
	is_following = true
	if follow_timer.is_stopped():
		follow_timer.start()

func _on_follow_timeout():
	is_following = false

# This function triggers when player dies
func _on_player_died():
	is_following = false
	is_lunging = false
	# Stop the follow timer if running
	if follow_timer.is_stopped() == false:
		follow_timer.stop()
	# Return to original position immediately
	position = start_position
	target_position = bottom_position
	moving_down = true
	has_lunged_this_pass = false

func perform_lunge():
	is_lunging = true
	var player_x = player_node.global_position.x
	var lunge_target = Vector2(player_x, position.y)

	var tween := create_tween()
	tween.tween_property(self, "position", lunge_target, abs(lunge_distance) / move_speed)
	tween.tween_property(self, "position", Vector2(position.x, start_position.y), abs(lunge_distance) / move_speed)
	tween.tween_callback(Callable(self, "resume_up_down_motion"))

func resume_up_down_motion():
	is_lunging = false
