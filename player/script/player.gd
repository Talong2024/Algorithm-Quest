class_name Player
extends CharacterBody2D

var move_speed: float = 500.0

func _physics_process(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * move_speed
	move_and_slide()
