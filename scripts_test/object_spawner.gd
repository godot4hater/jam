extends Node3D

var scene_to_instance = preload("res://object.tscn")
var spawning = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func instance_object():
	var object = scene_to_instance.instantiate()
	call_deferred("add_child",object)
