extends Node3D


@export var horizontal_acceleration : float = 2.0
@export var vertical_acceleration : float = 1.0
@export var min_vertical_angle : float = -0.1
@export var max_vertical_angle : float = 0.1
@export var mouse_acceleration : float = 0.005


func _process(delta: float) -> void:
	var joy_dir : Vector2
	joy_dir.x = Input.get_axis("pan_left", "pan_right")
	joy_dir.y = Input.get_axis("pan_down", "pan_up")
	joy_dir = joy_dir.normalized()
	
	rotate_from_vector(joy_dir * delta * Vector2(horizontal_acceleration, vertical_acceleration))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * mouse_acceleration)


func rotate_from_vector(vector: Vector2) -> void:
	if vector.length() == 0: return
	
	rotate_y(-vector.x)
	rotation.x -= vector.y
	rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)
