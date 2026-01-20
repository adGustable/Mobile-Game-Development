extends RigidBody2D

@export var respawn_position: Vector2

func toggle_gravity():
	gravity_scale = 1.0



func _ready():
	# Connect collision signal (assuming an Area2D is used for detection)
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):  # Ensure we collided with the player
		body.die()  # Assuming Player has a die() function
		set_deferred("global_transform", Transform2D(0, respawn_position))
		 # Reset velocity
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		gravity_scale = 0.0
