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

# fuck signals
signal putTimeInPlayersLabel (timeOutput : String)

func _ready():
	if not gMode.endless:
		riseRate = 1.9
		var timer: Timer = Timer.new()
		timer.wait_time = 1
		timer.one_shot = false
		timer.autostart = true
		timer.timeout.connect (_on_timer_timeout)
		add_child (timer)
	else:
		allowRaise = true
		moveValue = 50.0
		riseRate = 0.0075
		putTimeInPlayersLabel.emit ("SURVIVE")

func _on_timer_timeout() -> void:
	timeLeft -= 1
	putTimeInPlayersLabel.emit (ConvertTime (timeLeft))
	
	match timeLeft:
		480.0:
			allowRaise = true
			moveValue = 0.0
		360.0:
			allowRaise = true
			moveValue = 1.5
		240.0:
			allowRaise = true
			moveValue = 3.0
		120.0:
			allowRaise = true
			moveValue = 7.0
		0.0:
			allowRaise = true
			moveValue = 15.0

func _physics_process (delta) -> void:
	if allowRaise and trashCollected < TRASH_AMOUNT_WIN_CON:
		lavaRef.global_position.y = lerp (lavaRef.global_position.y, moveValue, delta * riseRate)
	
	if lavaRef.global_position.y >= moveValue:
		allowRaise = false

func ConvertTime (time: int) -> String:
	var minutes: int = floori (time / 60.0)
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]
