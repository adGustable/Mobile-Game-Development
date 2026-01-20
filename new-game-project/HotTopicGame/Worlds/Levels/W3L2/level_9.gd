extends Node2D

@onready var door = $GreenDoor
@onready var tilemap = door.get_node("TileMapLayer")
@onready var button = $GreenButton/Area2D 
@onready var green_button = $GreenButton
func _ready():
	
	var ball = $FallingSpikeball  
	var player = $PLAYERNODE/player
	
	player.player_died.connect(_on_player_died) 
	button.btn_pressed.connect(ball.toggle_gravity)
	button.btn_pressed.connect(func():
		door.visible = false
		tilemap.collision_enabled = false
	)
	
func _on_player_died():
	door.visible = true
	tilemap.collision_enabled = true
	green_button.frame = 0
