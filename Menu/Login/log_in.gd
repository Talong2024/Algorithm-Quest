extends Control

@onready var email_field: LineEdit = $Email
@onready var password_field: LineEdit = $Password
@onready var login_button: Button = $Login
@onready var signup_button: Button = $Signup
@onready var status_label: Label = $Label

const FIREBASE_API_KEY = "AIzaSyC6r1sMMfdWqcSB2_-FH7ZsySKrPLVogrk"
const LOGIN_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % FIREBASE_API_KEY

func _ready() -> void:
	if login_button and not login_button.is_connected("pressed", Callable(self, "_on_login_pressed")):
		login_button.connect("pressed", Callable(self, "_on_login_pressed"))
	else:
		printerr("Login button not found or already connected.")

	if signup_button and not signup_button.is_connected("pressed", Callable(self, "_on_signup_pressed")):
		signup_button.connect("pressed", Callable(self, "_on_signup_pressed"))
	else:
		printerr("Sign Up button not found or already connected.")

	if email_field:
		email_field.grab_focus()

func _on_login_pressed() -> void:
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
	http_request.request_completed.connect(_on_login_response)
	http_request.request(LOGIN_URL, headers, HTTPClient.METHOD_POST, json_string)

func _on_login_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	print(" Firebase login response:", response_text)

	var parsed = JSON.parse_string(response_text)

	if response_code == 200 and typeof(parsed) == TYPE_DICTIONARY and parsed.has("localId"):
		status_label.text = "Login successful! Redirecting..."
		print(" Login success:", parsed)

		await get_tree().create_timer(1.5).timeout
		var dashboard_scene = preload("res://Stack/Dungeon.tscn")
		get_tree().change_scene_to_packed(dashboard_scene)
	else:
		var error_msg = "Unknown error"
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("error"):
			error_msg = parsed["error"].get("message", "Unknown error")
		status_label.text = "Login failed: " + error_msg
		print(" Login failed:", response_text)

func _on_signup_pressed() -> void:
	var signup_scene = preload("res://Menu/Signup/SignUp.tscn")
	get_tree().change_scene_to_packed(signup_scene)
