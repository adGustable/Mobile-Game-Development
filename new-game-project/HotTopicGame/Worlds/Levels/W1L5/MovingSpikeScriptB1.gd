extends Node2D

@export var move_distance: float = 280
@export var move_speed: float = 200
@export var lunge_distance: float = -125
@export var lunge_height: float = 0  # Set this to the Y position where the block should lunge
@export var lunge_height_tolerance: float = 5  # How close to the lunge_height it needs to be
@export var player_wait_time: float = 2.0
var ready_to_check_lunge: bool = false

var start_position: Vector2
var top_position: Vector2
var bottom_position: Vector2
var target_position: Vector2
var moving_down: bool = true
var is_lunging: bool = false

var player_inside = false
var player_timer: Timer

func _ready():
	await get_tree().process_frame

	start_position = position
	top_position = start_position
	bottom_position = start_position + Vector2(0, move_distance)
	target_position = bottom_position

	# Create timer for player linger detection
	player_timer = Timer.new()
	player_timer.one_shot = true
	player_timer.wait_time = player_wait_time
	add_child(player_timer)
	player_timer.timeout.connect(_on_player_lingered)

	# Connect area signals
	$"../TriggerZoneB1".body_entered.connect(_on_body_entered)
	$"../TriggerZoneB1".body_exited.connect(_on_body_exited)

	# Give time to avoid triggering lunge at start
	await get_tree().create_timer(0.2).timeout  # Delay before listening to player_inside
	set_physics_process(true)


func _physics_process(delta):
	if is_lunging:
		return  # Pause all motion during lunge

	# Normal up/down motion
	var step = move_speed * delta
	position = position.move_toward(target_position, step)

	if position.distance_to(target_position) < step:
		moving_down = !moving_down
		target_position = bottom_position if moving_down else top_position

	# Continuous lunge check after player has lingered
	if ready_to_check_lunge and player_inside and abs(position.y - lunge_height) <= lunge_height_tolerance:
		perform_lunge()

# 🚨 TriggerZone functions
func _on_body_entered(body):
	if body.is_in_group("player"):
		if not player_inside:
			player_timer.start()
		player_inside = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		player_timer.stop()
		ready_to_check_lunge = false


func _on_player_lingered():
	if player_inside:
		ready_to_check_lunge = true


func perform_lunge():
	is_lunging = true
	ready_to_check_lunge = false  # Stop continuous checking once it lunges
	player_timer.stop()

	var lunge_target = position + Vector2(lunge_distance, 0)

	var tween := create_tween()
	tween.tween_property(self, "position", lunge_target, abs(lunge_distance) / move_speed)
	tween.tween_property(self, "position", start_position, abs(lunge_distance) / move_speed)
	tween.tween_callback(Callable(self, "resume_up_down_motion"))



func resume_up_down_motion():
	is_lunging = false
	# Recalculate top/bottom after lunge
	start_position = position
	top_position = start_position
	bottom_position = start_position + Vector2(0, move_distance)
	target_position = bottom_position if moving_down else top_position
