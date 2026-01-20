extends Node

var user_data = {"users": []}
var file_path = "user://user_data.json"

func _ready():
	load_user_data()

func load_user_data():
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()

		if error == OK:
			user_data = json.data
		else:
			user_data = {"users": []}
	else:
		user_data = {"users": []}


func save_user_data(username: String, password: String):
	user_data["users"].append({"username": username, "password": password})
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(user_data))
	file.close()

func validate_login(username: String, password: String) -> bool:
	for user in user_data["users"]:
		if user["username"] == username and user["password"] == password:
			return true
	return false

func is_username_taken(username: String) -> bool:
	for user in user_data["users"]:
		if user["username"] == username:
			return true
	return false
