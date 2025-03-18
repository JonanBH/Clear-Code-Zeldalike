extends Enemy

@export var closest_distance_from_player : float = 10.0


func _physics_process(delta: float) -> void:
	if position.distance_to(player.position) > closest_distance_from_player:
		move_to_player(delta)
	else:
		velocity = Vector3.ZERO
		move_state_machine.travel('Idle')


func _on_attack_timer_timeout() -> void:
	if position.distance_to(player.position) < attack_radius:
		$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		stop_movement(0.3, 2.0)
