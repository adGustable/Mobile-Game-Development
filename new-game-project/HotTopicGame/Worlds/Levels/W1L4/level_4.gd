extends Node2D

@onready var door: Area2D = $Door
@onready var DoorCollisionBox = door.get_node("CollisionShape2D")  # Adjust if it's deeper
@onready var DoorCollisionBox1 = door.get_node("CollisionShape2D2")  # Adjust if it's deeper
@onready var SpikeTriggerCollisionBox: CollisionShape2D = $HiddenSpikeTriggerArea/CollisionShape2D

var player: Node

func _ready() -> void:
	door.visible = false
	DoorCollisionBox.disabled = true
	DoorCollisionBox1.disabled = true
	
	SpikeTriggerCollisionBox.disabled = true
	
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))
	else:
		push_warning("Player node not found in group 'player'")

func _on_player_died():
	door.visible = false
