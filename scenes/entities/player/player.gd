extends CharacterBody3D

#jump
@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
# source: https://youtu.be/I0e1aGY6hXA?feature=shared

@export var base_speed : float = 4.0
@export var run_speed : float = 7.0
@export var defend_speed : float = 3.0
@export var speed_falloff_delta : float = 0.5
@export var acceleration : float = 0.75

var movement_input : Vector2 = Vector2.ZERO
var was_on_air : bool = false

@onready var camera : Camera3D = $CameraController/Camera3D
@onready var godette_skin: Node3D = $GodetteSkin
@onready var godette_skin_animation_player : AnimationPlayer = $GodetteSkin/AnimationPlayer

var defend :bool = false:
	set(value):
		if value and !defend:
			godette_skin.defend(true)
		elif defend and !value:
			godette_skin.defend(false)
		
		defend = value
		

func _process(delta: float) -> void:
	ability_logic()
	


func _physics_process(delta: float) -> void:
	
	move_logic(delta)
	jump_logic(delta)
	
	
	move_and_slide()


func move_logic(delta : float) -> void:
	movement_input = Vector2(Input.get_axis("left", "right"), 
			Input.get_axis("forward", "backward"))
			
	movement_input = movement_input.normalized().rotated(-camera.global_rotation.y)
	
	
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running : bool = Input.is_action_pressed("run")
	
	var speed = base_speed if !is_running else run_speed
	speed = defend_speed if defend else speed
	
	if movement_input != Vector2.ZERO:
		vel_2d += movement_input * speed * acceleration
		vel_2d = vel_2d.limit_length(speed)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		godette_skin.set_move_state("Running")
		
		var target_angle = -movement_input.angle() + PI/2
		godette_skin.rotation.y = rotate_toward(godette_skin.rotation.y, target_angle, 6.0 * delta)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, speed_falloff_delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		godette_skin.set_move_state("Idle")


func jump_logic(delta : float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
	else:
		godette_skin.set_move_state("Aerial")
	
	
		
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta


func ability_logic() -> void:
	if Input.is_action_just_pressed("ability"):
		godette_skin.attack()
	
	defend = Input.is_action_pressed("block")
