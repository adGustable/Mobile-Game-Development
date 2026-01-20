extends Control

@onready var http_request: HTTPRequest = $"../CanvasLayer/VBoxContainer/CatFact/HTTPRequest"
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var url = "https://meowfacts.herokuapp.com/"

func _on_cat_fact_pressed() -> void:
	var error = http_request.request(url)
	if error != OK:
		rich_text_label.text = "🐱 Could not connect to the cat fact server."

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		rich_text_label.text = "🐱 Failed to fetch cat fact. Check your internet connection!"
		return

	if response_code != 200:
		rich_text_label.text = "🐱 Server error: %d" % response_code
		return

	var json_str = body.get_string_from_utf8()
	var data = JSON.parse_string(json_str)

	if typeof(data) != TYPE_DICTIONARY or not data.has("data"):
		rich_text_label.text = "🐱 Unexpected response format."
		return

	var cat_fact = data["data"][0]
	rich_text_label.text = cat_fact
