extends Enemy


func _physics_process(delta: float) -> void:
	move_to_player(delta)


func melee_attack_animation() -> void:
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	stop_movement(1.5, 1.5)


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(1.0, 2.0)
	if position.distance_to(player.position) < attack_radius:
		melee_attack_animation() 
