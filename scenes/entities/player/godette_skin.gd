extends Node3D

const faces := {
	"default": Vector3.ZERO,
	"blink": Vector3(0.0, 0.5, 0.0)
}

@onready var move_state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/AttackStateMachine/playback")

@onready var extra_animation :AnimationNodeAnimation = $AnimationTree.get_tree_root().get_node("ExtraAnimation")

@onready var face_material : StandardMaterial3D = $Rig/Skeleton3D/Godette_Head.get_surface_override_material(0)

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var is_attacking : bool = false
var squash_and_stretch : float = 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		scale = Vector3(negative, squash_and_stretch , negative)


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


func switch_weapon(weapon_active : bool) -> void:
	if weapon_active:
		$Rig/Skeleton3D/RightHandSlot/sword_1handed2.show()
		$Rig/Skeleton3D/RightHandSlot/wand2.hide()
	else:
		$Rig/Skeleton3D/RightHandSlot/sword_1handed2.hide()
		$Rig/Skeleton3D/RightHandSlot/wand2.show()


func cast_spell() -> void:
	if not is_attacking:
		#change extra animation to spellcast
		extra_animation.animation = "Spellcast_Shoot"
		$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func hit() -> void:
	#change extra animation to hit_a
	extra_animation.animation = "Hit_A"
	$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func change_face(expression : String) -> void:
	face_material.uv1_offset = faces[expression]


func _on_blink_timer_timeout() -> void:
	change_face("blink")
	await get_tree().create_timer(0.15).timeout
	change_face("default")
	$BlinkTimer.wait_time = rng.randf_range(1.5, 3.0)
	
