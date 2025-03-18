class_name Enemy
extends CharacterBody3D

@export var walk_speed : float = 3.0
@export var rotation_speed : float = 6.0

@export var notice_radius : float = 30.0
@export var attack_radius : float = 3.0

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var skin : Node3D = get_node("Skin")
@onready var move_state_machine = $AnimationTree.get('parameters/MoveStateMachine/playback')
@onready var attack_animation : AnimationNodeAnimation = $AnimationTree.get_tree_root().get_node("AttackAnimation")
@onready var speed : float = walk_speed

var speed_modifier : float = 1.0
var squash_and_stretch : float = 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		skin.scale = Vector3(negative, squash_and_stretch , negative)

var rng = RandomNumberGenerator.new()


func move_to_player(delta : float) -> void:
	if position.distance_to(player.position) < notice_radius:
		var target_dir : Vector3 = (player.position - position).normalized()
		var target_vec2 : Vector2 = Vector2(target_dir.x, target_dir.z)
		var target_angle : float = -target_vec2.angle() + PI/2
		rotation.y = rotate_toward(rotation.y, target_angle, rotation_speed * delta)
		
		if position.distance_to(player.position) > attack_radius:
			velocity = Vector3(target_vec2.x, 0, target_vec2.y) * speed * speed_modifier
			move_state_machine.travel('Walk')
		else:
			velocity = Vector3.ZERO
			move_state_machine.travel('Idle')
		move_and_slide()


func stop_movement(start_duration : float, end_duration : float) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)


func hit() -> void:
	if $Timers/InvulnerableTimer.time_left: 
		return
	
	print("Enemy was hit")
	do_squash_and_stretch(0.85, 0.1)
	$Timers/InvulnerableTimer.start()


func do_squash_and_stretch(value: float, duration: float = 0.1) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "squash_and_stretch", value, duration)
	tween.tween_property(self, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
