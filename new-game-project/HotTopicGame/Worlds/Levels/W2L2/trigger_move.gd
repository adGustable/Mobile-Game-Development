extends Area2D

signal triggered_moving_ground

func _ready():
	body_entered.connect(_on_body_entered)  

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("triggered_moving_ground")
		#print("Trigger: Player detected!")
