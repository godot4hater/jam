extends CanvasLayer

@export var GAME_PACKED: PackedScene

@onready var play_game: Button = $Background/PlayGame
@onready var options: Button = $Background/Endless
@onready var quit: Button = $Background/Quit
@onready var background: TextureRect = $Background

func _ready():
	Input.set_mouse_mode (Input.MOUSE_MODE_VISIBLE)
	
func _on_play_game_pressed() -> void:
	play_game.hide()
	options.hide()
	quit.hide()
	
	var game = GAME_PACKED.instantiate()
	game.set_process_input(false)
	game.set_physics_process(false)
	#get_tree().root.add_child(game)
	#get_tree().current_scene = game
	get_tree().call_deferred("change_scene_to_file", "res://scenes_levels/playground.tscn")
	
	var tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(background, "position:y", 720.0, 0.25)
	tween.tween_callback(queue_free)
	
	await tween.finished
	game.set_process_input(true)
	game.set_physics_process(true)


func _on_options_pressed() -> void:
	play_game.hide()
	options.hide()
	quit.hide()
	gMode.endless = true
	
	var game = GAME_PACKED.instantiate()
	game.set_process_input(false)
	game.set_physics_process(false)
	get_tree().call_deferred("change_scene_to_file", "res://scenes_levels/playground.tscn")
	#get_tree().root.add_child(game)
	#get_tree().current_scene = game
	
	var tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(background, "position:y", 720.0, 0.25)
	tween.tween_callback(queue_free)
	
	await tween.finished
	game.set_process_input(true)
	game.set_physics_process(true)

func _on_quit_pressed() -> void:
	get_tree().quit()
