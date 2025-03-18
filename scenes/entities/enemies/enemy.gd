class_name Enemy
extends CharacterBody3D

@export var walk_speed : float = 3.0
@export var rotation_speed : float = 6.0

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var skin = get_node("Skin")


func move_to_player(delta : float) -> void:
	var target_dir : Vector3 = (player.position - position).normalized()
	var target_vec2 : Vector2 = Vector2(target_dir.x, target_dir.z)
	var target_angle : float = -target_vec2.angle() + PI/2
	
	velocity = Vector3(target_vec2.x, 0, target_vec2.y) * walk_speed
	rotation.y = rotate_toward(rotation.y, target_angle, rotation_speed * delta)
	move_and_slide()
	
