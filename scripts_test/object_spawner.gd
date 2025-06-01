extends Node3D

var trash1 = preload("res://test_trash_pile.tscn")
var trash2 = preload("res://scenes_trash/rigid_bean_box.tscn")
var trash3 = preload("res://scenes_trash/rigid_bean_can.tscn")
var trash4 = preload("res://scenes_trash/rigid_bean_soda.tscn")
var trash_array = [trash1,trash2,trash3,trash4]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func instance_object():
	var random = randi() % trash_array.size()
	var object = trash_array[random].instantiate()
	call_deferred("add_child",object)
