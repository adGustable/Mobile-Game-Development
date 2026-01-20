extends CharacterBody2D
signal player_died
@export var respawn_position: Vector2
@export var speed: float = 250.0
@export var jump_velocity: float = -330.0
@export var ice_friction: float = 0.99
@export var ice_acceleration: float = 0.01  #Lower feels worse
@export var ice_momentum_duration: float = 0.3  # How long momentum lasts after leaving ice
@export var joystick_left: VirtualJoystick
@export var joystick_right: VirtualJoystick
@export var tilemap_layer: TileMapLayer  # Assign your TileMapLayer in the editor

var gravity = ProjectSettings.get("physics/2d/default_gravity")
var is_on_ice: bool = false
var is_on_tile: bool = false
var ice_momentum_timer: float = 0.0
var ice_momentum_velocity: Vector2 = Vector2.ZERO
var was_on_ice_last_frame: bool = false
var was_on_ice_last: bool = false

func _ready():
	# Auto-find TileMapLayer
	if not tilemap_layer:
		# Since TileMapLayer is at the main scene level, we need to go up to find it
		tilemap_layer = get_tree().get_first_node_in_group("tilemap")
		if not tilemap_layer:
			pass #Give up
	

func _physics_process(_delta):
	# Check if player is on ice
	check_ice_collision()
	
	# Handle ice momentum when transitioning off ice
	if was_on_ice_last and not is_on_ice:
		# Just left ice - start momentum timer and store velocity
		ice_momentum_timer = ice_momentum_duration
		ice_momentum_velocity = velocity
		#print("Left ice! Starting momentum with velocity: ", ice_momentum_velocity)
	
	elif not was_on_ice_last and is_on_ice:
		# On ice - reset momentum
		ice_momentum_timer = 0.0
	elif ice_momentum_timer > 0.0:
		# Still in momentum phase - countdown
		ice_momentum_timer -= _delta
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * _delta
	else:
		velocity.y = 0.0
	
	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if is_on_ice and is_on_tile:
		# Ice physics: gradual acceleration and sliding
		var target_velocity = direction * (speed * 1.7 ) #1.7
		
		# Much slower acceleration on ice
		velocity.x = lerp(velocity.x, target_velocity, ice_acceleration)
		
		# Apply ice friction when not inputting
		if direction == 0:
			velocity.x *= ice_friction
			
			# Clamp very small velocities to zero
			if abs(velocity.x) < 5.0:
				velocity.x = 0.0
			
		
	elif was_on_ice_last:
		# Ice momentum phase - preserve sliding motion
		#print("Ice momentum active! Timer: ", ice_momentum_timer)
		
		if is_on_tile:
			# On ground but with ice momentum - gradual deceleration
			var momentum_strength = ice_momentum_timer / ice_momentum_duration
			
			if direction == 0:
				# No input - just slide with momentum and gradual friction
				velocity.x = ice_momentum_velocity.x * momentum_strength
			else:
				# Input while sliding - blend momentum with normal movement
				var normal_velocity = direction * speed
				var momentum_velocity = ice_momentum_velocity.x * momentum_strength
				# Blend between momentum and normal movement
				velocity.x = lerp(normal_velocity, momentum_velocity, momentum_strength * 0.7)
		else:
			# In air with ice momentum - preserve horizontal velocity for realistic physics
			if direction == 0:
				# No input in air - maintain momentum
				velocity.x = ice_momentum_velocity.x
			else:
				# Slight air control but mostly preserve momentum
				var air_control_strength = 0.3
				var target_velocity = direction * speed
				velocity.x = lerp(velocity.x, target_velocity, air_control_strength * _delta)
	else:
		# Normal physics - no ice, no momentum
		if is_on_floor():
			velocity.x = direction * speed
		else:
			# Normal air control
			#var air_control_strength = 2.5
			#var target_velocity = direction * speed
			#velocity.x = lerp(velocity.x, target_velocity, air_control_strength * _delta)
			velocity.x = direction * speed
	
	# Jump if grounded - with platform detection only when needed
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity  # Normal jump
			
		
	# Store ice state for next frame
	was_on_ice_last_frame = is_on_ice
	
	# Apply movement using physics
	move_and_slide()
	
	# Death check
	if position.y > 700:
		die()
	
	# Animation
	if velocity.y != 0:
		$AnimatedSprite2D.play("up")
	elif velocity.x != 0:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.stop()

func check_ice_collision():
	if not tilemap_layer:
		is_on_ice = false
		return
	
	# Get player's bottom position (feet)
	var player_global_pos = global_position
	var collision_shape = $CollisionShape2D
	var shape_bottom_offset = Vector2.ZERO
	
	shape_bottom_offset = Vector2(0, collision_shape.shape.height / 2)
	
	var feet_position = player_global_pos + shape_bottom_offset
	
	# Convert to tilemap's local space
	var local_pos = tilemap_layer.to_local(feet_position)
	var tile_pos = tilemap_layer.local_to_map(local_pos)
	
	# Debug position information
	#print("Player global pos: ", player_global_pos, " | Feet pos: ", feet_position, " | Tile pos: ", tile_pos)
	
	# Check multiple positions around the player's feet for better detection
	var check_positions = [
		#tile_pos, 
		Vector2i(tile_pos.x - 1, tile_pos.y + 1),  
		Vector2i(tile_pos.x + 1, tile_pos.y + 1),  
		Vector2i(tile_pos.x - 2, tile_pos.y + 1),  
		Vector2i(tile_pos.x + 2, tile_pos.y + 1),   
		Vector2i(tile_pos.x, tile_pos.y + 1), 
	]
	

	for check_pos in check_positions:
		var source_id = tilemap_layer.get_cell_source_id(check_pos)
		if source_id != -1:
			is_on_tile = true
			var tile_data = tilemap_layer.get_cell_tile_data(check_pos)
			if tile_data:
				var is_ice_tile = tile_data.get_custom_data("is_ice")
				#print("Checking tile at ", check_pos, " - Source ID: ", source_id, " | is_ice: ", is_ice_tile)
				if is_ice_tile:
					is_on_ice = true
				else:
					is_on_ice = false
				
	
	# Update was_on_ice_last only when we find a tile (player is touching ground)
	if is_on_tile:
		was_on_ice_last = is_on_ice
	

func die():
	emit_signal("player_died")
	Event.emit_signal("deaths", 1)
	position = respawn_position
	velocity = Vector2.ZERO
	# Reset ice-related variables
	is_on_ice = false
	ice_momentum_timer = 0.0
	ice_momentum_velocity = Vector2.ZERO
	
