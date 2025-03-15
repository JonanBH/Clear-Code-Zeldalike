extends Node3D


@onready var move_state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/AttackStateMachine/playback")

var is_attacking : bool = false


func set_move_state(state_name : String) -> void:
	move_state_machine.travel(state_name)


func attack() -> void:
	if !is_attacking:
		attack_state_machine.travel("Slice" if $SecondAttackTimer.time_left else "Chop")
		$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func attack_toggle(value : bool) -> void:
	is_attacking = value


func defend(forward : bool) -> void:
	var tween : Tween = create_tween()
	tween.tween_method(_defend_change, 1.0 -float(forward), float(forward), 0.25)


func _defend_change(value : float) -> void:
	$AnimationTree.set("parameters/BlendShield/blend_amount", value)
