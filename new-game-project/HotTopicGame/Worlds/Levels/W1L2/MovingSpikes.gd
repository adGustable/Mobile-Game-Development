extends Node2D

@export var move_distance: Vector2 = Vector2(60,0)  # Move spikes up by 50 pixels
@export var move_speed: float = 400  # Movement speed

var start_position: Vector2
var target_position: Vector2
var moving: bool = false
var trigger: Node
var player: Node
var area: Area2D  # Reference to Area2D

func _ready():
	start_position = position
	target_position = start_position + move_distance  # Move to the right

	# Find the trigger
	trigger = get_node("/root/Level2/MovingSpikeTriggerArea")
	if trigger:
		trigger.connect("player_triggered", Callable(self, "_on_trigger"))

	player = get_tree().get_first_node_in_group("player")
	#Debugging
	#if player:
		#print("✅ Player found: ", player)
		#print("→ Type: ", player.get_class())
		#print("Group", player.get_groups())
		#print("→ Script: ", player.get_script())
		#print("→ Has signal 'player_died': ", player.has_signal("player_died"))
	#else:
		#print("❌ No player node found in group 'player'")
	player.connect("player_died", Callable(self, "_reset_block"))
	
	# Find the Area2D inside this node
	area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		# print("Area Found")
	# else:
		# print("ERROR: No Area2D found in Spikes!")

func _on_trigger():
	#print("Spikes: Moving up!")
	moving = true

func _physics_process(delta):
	if moving:
		position = position.move_toward(target_position, move_speed * delta)
		if position == target_position:
			moving = false  # Stop when it reaches the target

func _reset_block():
	position = start_position  # Move the block back to the original position
	moving = false  # Stop the movement
