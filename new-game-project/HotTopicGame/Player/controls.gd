extends Node2D

func _ready():
	# Load settings first to ensure we have the current preference
	%FileManager.load_settings()
	
	# Set up controls based on platform and user preference
	setup_controls()

func setup_controls():
	if OS.get_name() != "Android":
		# Hide on PC
		get_node("CanvasLayer/Left").visible = false
		get_node("CanvasLayer/Right").visible = false
		get_node("CanvasLayer/JumpButton").visible = false
		get_node("CanvasLayer/Virtual Joystick").visible = false
	else:
		get_node("CanvasLayer/JumpButton").visible = true  # Always show jump button
		
		if not Event.use_joystick:
			# Show joystick, hide buttons
			get_node("CanvasLayer/Virtual Joystick").visible = true
			get_node("CanvasLayer/Left").visible = false
			get_node("CanvasLayer/Right").visible = false
		else:
			# Show buttons, hide joystick
			get_node("CanvasLayer/Virtual Joystick").visible = false
			get_node("CanvasLayer/Left").visible = true
			get_node("CanvasLayer/Right").visible = true
