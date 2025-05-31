@tool
class_name Broom extends Marker3D

@export var holstered: bool : set = _set_holstered

@export var anim_player: AnimationPlayer

func _set_holstered(value: bool) -> void:
	holstered = value
	if not is_inside_tree():
		await ready
		
	if holstered: anim_player.play("retract")
	else: anim_player.play_backwards("retract")
