extends Control

@onready var email_field: LineEdit = $EmailLineEdit
@onready var password_field: LineEdit = $PasswordLineEdit
@onready var status_label: Label = $StatusLabel
@onready var login_button: Button = $LoginButton
@onready var signup_button: Button = $SignUpButton



func _ready():
	if email_field:
		email_field.grab_focus()
	else:
		printerr("Email field not found — check node path.")

	if signup_button:
		signup_button.connect("pressed", Callable(self, "_on_signup_pressed"))
	else:
		printerr("Sign Up button not found — check node path.")

func _on_LoginButton_pressed():
	var email = email_field.text.strip_edges()
	var password = password_field.text.strip_edges()

	if email == "" or password == "":
		status_label.text = "Please enter both email and password."
		return

	Firebase.Auth.connect("login_succeeded", Callable(self, "_on_login_success"))
	Firebase.Auth.connect("login_failed", Callable(self, "_on_login_fail"))

	Firebase.Auth.sign_in_with_email_and_password(email, password)

func _on_login_success(user_data):
	status_label.text = "Login successful! Redirecting..."

	await get_tree().create_timer(1.5).timeout
	var dashboard_scene = preload("res://Stack/Dungeon.tscn")
	get_tree().change_scene_to(dashboard_scene)

func _on_login_fail(error_msg):
	status_label.text = "Login failed: " + error_msg


func _on_signup_pressed() -> void:
	var signup_scene = preload("res://Menu/Signup/SignUp.tscn")
	get_tree().change_scene_to_packed(signup_scene)
