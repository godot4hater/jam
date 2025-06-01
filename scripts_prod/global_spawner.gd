extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if !gMode.endless:
		var children_array = get_children()
		var random : int
		
		var trashbags = 10
		while trashbags > 0:
			random = randi() % children_array.size()
			if children_array[random].get_child_count() == 0:
				children_array[random].instance_object()
				trashbags -= 1
		

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
		print("Spawning trash!")
		var random = randi() % childless_children.size()
		childless_children[random].instance_object()
	else:
		print("No space!")
		
	$spawnerTimer.wait_time = 15.0
	$spawnerTimer.start()
