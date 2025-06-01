extends Node3D

var trashCollected : int   		    = 0
const TRASH_AMOUNT_WIN_CON : int    = 10
var timePassed : float     		    = 0.0
# hard coding 10 minute timer
var timeLeft : float     		    = 600.0
var riseRate : float                = 1.9
var allowRaise : bool               = false
var moveValue : float               = 0.0

# hard coded references
@onready var lavaRef : AnimatableBody3D = $Lava
@onready var bgmPlay : AudioStreamPlayer = $BGM
var music1  = preload ("res://assets/sounds/normalStart.mp3")
var music2  = preload ("res://assets/sounds/dangerLoop.mp3")
# fuck signals
signal putTimeInPlayersLabel (timeOutput : String)

func _ready():
	bgmPlay.volume_db = -12.0
	if not gMode.endless:
		bgmPlay.stream = music1
		bgmPlay.play()
		riseRate = 1.9
		var timer: Timer = Timer.new()
		timer.wait_time = 1
		timer.one_shot = false
		timer.autostart = true
		timer.timeout.connect (_on_timer_timeout)
		add_child (timer)
	else:
		bgmPlay.stream = music2
		bgmPlay.play()
		allowRaise = true
		moveValue = 50.0
		riseRate = 0.0075
		putTimeInPlayersLabel.emit ("SURVIVE")
		
		var timer2: Timer = Timer.new()
		timer2.wait_time = 120
		timer2.one_shot = true
		timer2.autostart = true
		timer2.timeout.connect (_on_timer_timeout2)
		add_child (timer2)
		
		var timer3: Timer = Timer.new()
		timer3.wait_time = 550
		timer3.one_shot = true
		timer3.autostart = true
		timer3.timeout.connect (_on_timer_timeout3)
		add_child (timer3)

func _on_timer_timeout() -> void:
	timeLeft -= 1
	putTimeInPlayersLabel.emit (ConvertTime (timeLeft))
	
	match timeLeft:
		480.0:
			allowRaise = true
			moveValue = 1.5
		360.0:
			allowRaise = true
			moveValue = 5.0
		240.0:
			allowRaise = true
			moveValue = 7.0
		120.0:
			bgmPlay.stream = music2
			bgmPlay.play()
			allowRaise = true
			moveValue = 9.0
		0.0:
			allowRaise = true
			moveValue = 15.0

func _on_timer_timeout2() -> void:
	riseRate = 0.012

func _on_timer_timeout3() -> void:
	riseRate = 0.025
	
func _physics_process (delta) -> void:
	if allowRaise and trashCollected < TRASH_AMOUNT_WIN_CON:
		lavaRef.global_position.y = lerp (lavaRef.global_position.y, moveValue, delta * riseRate)
	
	if lavaRef.global_position.y >= moveValue:
		allowRaise = false

func ConvertTime (time: int) -> String:
	var minutes: int = floori (time / 60.0)
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]
