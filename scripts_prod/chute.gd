extends Node3D

@onready var gameLoopRef = get_tree().get_root().get_node ("testlvl")
@onready var lavaRef : AnimatableBody3D = get_tree().get_root().get_node ("testlvl/Lava")
var gameLoopDisabled = false
signal reduceTrashCounter()
signal playerWins()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	CheckIfPlayerWon()
	print("NOM NOM NOM")
	body.queue_free()
	
func _on_character_body_3d_emit_broom_pickup_trash() -> void:
	CheckIfPlayerWon()
	
func CheckIfPlayerWon():
	gameLoopRef.trashCollected += 1
	
	if not gameLoopDisabled:
		reduceTrashCounter.emit()
		
		if gMode.endless:
			gameLoopRef.allowRaise = false
			lavaRef.global_position.y -= 2.5
			var timer2: Timer = Timer.new()
			timer2.wait_time = 2
			timer2.one_shot = false
			timer2.autostart = true
			timer2.timeout.connect (_on_timer_timeout2)
			add_child (timer2)
		
	if gameLoopRef.trashCollected >= 10 and not gameLoopDisabled and not gMode.endless:
		playerWins.emit()
		
		var timer: Timer = Timer.new()
		timer.wait_time = 6
		timer.one_shot = false
		timer.autostart = true
		timer.timeout.connect (_on_timer_timeout)
		add_child (timer)
		
		gameLoopDisabled = true
	
func _on_timer_timeout() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes_levels/main_menu.tscn")
	
func _on_timer_timeout2() -> void:
	gameLoopRef.allowRaise = true
