extends Node3D

var scene_to_instance = preload("res://object.tscn")
var spawning = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count() == 1 && spawning == 0:
		print("Object deleted...")
		spawning = 1
		var timer = get_child(0)
		timer.start_timer()
		

func _on_timer_timeout():
	print("Spawning object...")
	spawning = 0
	instance_object()
	
func instance_object():
	var object = scene_to_instance.instantiate()
	call_deferred("add_child",object)
