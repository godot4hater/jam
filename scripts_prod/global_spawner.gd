extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_spawner_timer_timeout():
	print("Spawning!")
	var children_array = get_children()
	var childless_children = []
	
	for n in range(1, children_array.size()):
		if children_array[n].get_child_count() == 0:
			childless_children.append(children_array[n])
			
	if !childless_children.is_empty():
		print("Spaning trash!")
		var random = randi() % childless_children.size()
		childless_children[random].instance_object()
	else:
		print("No space!")
		
	$spawnerTimer.wait_time = 5.0
	$spawnerTimer.start()
