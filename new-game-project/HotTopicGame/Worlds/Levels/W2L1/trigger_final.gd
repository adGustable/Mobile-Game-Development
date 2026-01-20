extends Area2D

signal trigger_final_spike

func _ready():
	
	body_entered.connect(_on_body_entered) 

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("trigger_final_spike")
		#print("Trigger: Spike!")
