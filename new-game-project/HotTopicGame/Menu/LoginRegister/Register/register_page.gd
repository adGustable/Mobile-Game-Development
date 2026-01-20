extends Node

@onready var scene_tree = get_tree()

func _on_register_button_down() -> void:
	var username = $BoardTexture/UsernameLabel/UsernameTextBox.text
	var password = $BoardTexture/PasswordLabel/PasswordTextBox.text
	var confirm = $BoardTexture/ConfirmPasswordLabel/ConfirmPasswordTextBox.text
	
	# Validate input fields
	if username == "" or password == "" or confirm == "":
		print("Please fill in all fields")
	elif password != confirm:
		print("Please ensure password and confirmed password match")
		return

	# Optional: Prevent duplicate usernames
	if Auth.is_username_taken(username):
		print("Username already exists")
		return

	# Save user data via Auth singleton
	Auth.save_user_data(username, password)
	print("User registered successfully")
	# Redirect to the login page
	scene_tree.change_scene_to_file("res://HotTopicGame/Menu/Main/MainMenu.tscn")

func _on_exit_button_down() -> void:
	# Path to your Main Login Page scene
	var mlogin_scene = load("res://HotTopicGame/Menu/LoginRegister/MainLogin.tscn") 
	if mlogin_scene:
	# Change to the Login Page scene
		get_tree().change_scene_to_packed(mlogin_scene)
	else:
		print("ERROR!")
