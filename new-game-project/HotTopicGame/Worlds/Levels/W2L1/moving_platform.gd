extends StaticBody2D

var angle = 0.0
var radius = 150.0
var speed = 1.0
var center_position = Vector2(118, 0)
var previous_position: Vector2
var players_on_platform: Array = []

func _ready():
	previous_position = position
	

func _physics_process(delta):  # Use _physics_process for consistent timing
	previous_position = position
	
	# Update platform position (smooth circular motion)
	angle += speed * delta
	position = Vector2(
		center_position.x + radius * cos(angle),
		center_position.y + radius * sin(angle)
	)
	# Move players with the platform
	move_players_with_platform()

func move_players_with_platform():
	var movement = position - previous_position
	
	for player in players_on_platform:
		if is_instance_valid(player):
			# Move player with platform
			player.global_position += movement

func _on_player_entered(body):
	if body.is_in_group("player") and body not in players_on_platform:
		players_on_platform.append(body)
		#print("Player on platform")

func _on_player_exited(body):
	if body.is_in_group("player") and body in players_on_platform:
		players_on_platform.erase(body)
		#print("Player left platform")
