extends AnimatedSprite2D

@onready var door: Area2D = $"../Door"
@onready var door_collision = door.get_node("CollisionShape2D")  # Adjust if it's deeper
@onready var door_collision1 = door.get_node("CollisionShape2D2")  # Adjust if it's deeper
@onready var MoveDoorButtonArea: Area2D = $Area2D
@onready var SpikeTriggerCollisionBox: CollisionShape2D = $"../HiddenSpikeTriggerArea/CollisionShape2D"


func _ready() -> void:
	MoveDoorButtonArea.connect("pushed", Callable(self, "_make_door_visible"))

func _make_door_visible():
	door.visible = true
	door_collision.disabled = false
	door_collision1.disabled = false
	SpikeTriggerCollisionBox.disabled = false
	
