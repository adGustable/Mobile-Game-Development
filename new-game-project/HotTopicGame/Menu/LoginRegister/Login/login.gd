extends Node

@onready var scene_tree = get_tree()

func _on_login_btn_pressed():
	var username = $BoardTexture/UsernameLabel/UsernameTextBox.text
	var password = $BoardTexture/PasswordLabel/PasswordTextBox.text

	# Validate input fields
	if username == "" or password == "":
		print("Please fill in all fields")
		return

	# Use Auth singleton to validate login
	if Auth.validate_login(username, password):
		print("Login successful")
		# Transition to the main game scene
		scene_tree.change_scene_to_file("res://HotTopicGame/Menu/Main/MainMenu.tscn")
	else:
		print("Invalid username or password")

func _on_exit_btn_pressed() -> void:
	# Path to your Login Main Page scene
	var main_scene = load("res://HotTopicGame/Menu/LoginRegister/MainLogin.tscn") 
	if main_scene:
	# Change to the Login Page scene
		get_tree().change_scene_to_packed(main_scene)
	else:
		print("ERROR!")
