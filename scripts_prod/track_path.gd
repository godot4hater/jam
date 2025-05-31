@tool
extends Path3D

@export var speed := 0.5
@export_tool_button("Fix Track") var fix_track_button = _fix_track

func _ready() -> void:
	_fix_track()

func _physics_process(delta: float) -> void:
	for f: PathFollow3D in get_children():
		f.progress_ratio -= speed * delta

func _fix_track() -> void:
	for i in get_child_count():
		(get_child(i) as PathFollow3D).progress_ratio = float(i) / float(get_child_count())
