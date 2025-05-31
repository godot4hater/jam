@tool
class_name Broom extends Marker3D

@export var holstered: bool : set = _set_holstered

@export var anim_player: AnimationPlayer
@export var spring_bone: SpringBoneSimulator3D

func _set_holstered(value: bool) -> void:
	holstered = value
	if not is_inside_tree():
		await ready
	
	spring_bone.influence = 0.2 if holstered else 0.2
	if holstered: anim_player.play("retract")
	else: anim_player.play_backwards("retract")
