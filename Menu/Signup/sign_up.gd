extends Control

@onready var email_field: LineEdit = $Email
@onready var password_field: LineEdit = $Password
@onready var status_label: Label = $Label
@onready var signup_button: Button = $Button   # ✅ make sure this matches your scene tree

const FIREBASE_API_KEY = "AIzaSyC6r1sMMfdWqcSB2_-FH7ZsySKrPLVogrk"
const SIGNUP_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % FIREBASE_API_KEY
const DATABASE_URL = "https://algoquest-3f812-default-rtdb.asia-southeast1.firebasedatabase.app"

# ✅ CHANGE THIS to the actual path of your login scene
const LOGIN_SCENE = "res://scenes/login.tscn"

func _ready() -> void:
	if signup_button and not signup_button.is_connected("pressed", Callable(self, "_on_button_pressed")):
		signup_button.connect("pressed", Callable(self, "_on_button_pressed"))
	else:
		push_error("signup_button not found or already connected!")

func _on_button_pressed() -> void:
	var email = email_field.text.strip_edges()
	var password = password_field.text.strip_edges()

	if email == "" or password == "":
		status_label.text = "Please enter both email and password."
		return

	var payload = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	var json_string = JSON.stringify(payload)
	var headers = PackedStringArray(["Content-Type: application/json"])

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_signup_response)
	http_request.request(SIGNUP_URL, headers, HTTPClient.METHOD_POST, json_string)

func _on_signup_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	print(" Firebase signup response:", response_text)

	var parsed = JSON.parse_string(response_text)

	if response_code == 200 and typeof(parsed) == TYPE_DICTIONARY and parsed.has("localId"):
		var user_data: Dictionary = parsed
		var local_id: String = user_data["localId"]
		status_label.text = "Signup successful! Welcome, " + str(user_data.get("email", ""))
		print(" Signup success:", user_data)

		_initialize_progress(local_id)

		# ✅ Return to login scene after a short delay
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file(LOGIN_SCENE)
	else:
		var error_msg = "Unknown error"
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("error"):
			error_msg = parsed["error"].get("message", "Unknown error")
		status_label.text = "Signup failed: %s (%s)" % [error_msg, str(response_code)]
		print(" Signup failed:", response_text)

func _initialize_progress(local_id: String) -> void:
	var progress_data = {
		"Location1": 0,
		"Location2": 0,
		"Location3": 0,
		"Location4": 0,
		"Location5": 0
	}
	var json_string = JSON.stringify(progress_data)
	var headers = PackedStringArray(["Content-Type: application/json"])
	var url = "%s/progress/%s.json" % [DATABASE_URL, local_id]

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_progress_response)
	http_request.request(url, headers, HTTPClient.METHOD_PUT, json_string)

func _on_progress_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	print(" Firebase progress response:", response_text)

	if response_code == 200:
		status_label.text = "Progress initialized successfully!"
		print(" Progress initialized:", response_text)
	else:
		status_label.text = "Progress init failed: %s" % str(response_code)
		print(" Progress init failed:", response_code, response_text)
