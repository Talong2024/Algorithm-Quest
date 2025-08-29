class_name Player
extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction = Vector2.ZERO
var move_speed: float = 500.0
var state : String = "Idle"

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D 

func _physics_process(delta):

	direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * move_speed
	move_and_slide()
	
	UpdateAnimation()


func SetDirection() -> bool:
	
	return true
	
func UpdateAnimation() -> void:
	if direction != Vector2.ZERO:
		animation_player.play("Walking animation")
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	else:
		animation_player.play("Idle_side")
	
	
