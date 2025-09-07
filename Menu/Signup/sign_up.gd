extends Control

@onready var username_field = $UsernameLineEdit
@onready var email_field = $EmailLineEdit
@onready var password_field = $PasswordLineEdit
@onready var status_label = $StatusLabel

func _on_signup_button_pressed():
	var email = email_field.text.strip_edges()
	var password = password_field.text.strip_edges()

	if email == "" or password == "":
		status_label.text = "Please enter both email and password."
		return

	Firebase.Auth.connect("signup_succeeded", Callable(self, "_on_signup_success"))
	Firebase.Auth.connect("signup_failed", Callable(self, "_on_signup_fail"))

	Firebase.Auth.create_user_with_email_and_password(email, password)

func _on_signup_success(user_data):
	status_label.text = "Signup successful! Welcome, " + user_data.email

func _on_signup_fail(error_msg):
	status_label.text = "Signup failed: " + error_msg
