extends Enemy

const simple_attacks = {
	'slice': "2H_Melee_Attack_Slice",
	'spin' : "2H_Melee_Attack_Spin",
	'range': "1H_Melee_Attack_Stab"
}

@export var meelee_attack_range : float = 5.0
@export var spin_speed : float = 6

var spinning : bool = false

func _physics_process(delta: float) -> void:
	move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(4.0, 5.5)
	
	# 4 Animations to control:
	# 2 melee attacks
	# 2 ranged attacks
	
	if position.distance_to(player.position) < meelee_attack_range:
		melee_attack_animation()
	else:
		if rng.randi() % 2:
			range_attack_animation()
		else:
			spin_attack_animation()


func melee_attack_animation() -> void:
	attack_animation.animation = simple_attacks['slice' if rng.randi() % 2 else 'spin']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	stop_movement(1.5, 1.5)


func range_attack_animation() -> void:
	attack_animation.animation = simple_attacks['range']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	stop_movement(1.5, 1.5)


func spin_attack_animation() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "speed", spin_speed, 0.5)
	tween.tween_method(_spin_transition, 0.0, 1.0, 0.3)
	$Timers/AttackTimer.stop()
	spinning = true


func _spin_transition(value : float) -> void:
	$AnimationTree.set("parameters/SpinBlend/blend_amount", value)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if spinning:
		spinning = false
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
		
		var tween : Tween = create_tween()
		tween.tween_property(self, "speed", walk_speed, 0.5)
		tween.tween_method(_spin_transition, 1.0, 0.0, 0.3)
		spinning = false
		$Timers/AttackTimer.start()


func hit() -> void:
	if $Timers/InvulnerableTimer.time_left: 
		return
	
	print("Boss was hit")
	$Timers/InvulnerableTimer.start()
