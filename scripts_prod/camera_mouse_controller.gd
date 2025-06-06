extends Node3D

@onready var yawRef = $CameraYaw
@onready var pitchRef = $CameraYaw/CameraPitch
@onready var cameraRef = $CameraYaw/CameraPitch/SpringArm3D/Camera3D
@onready var springDist = $CameraYaw/CameraPitch/SpringArm3D
@onready var playerRef = get_parent()

@export var PITCH_MIN : float 		= -80.0
@export var PITCH_MAX : float 		= 40.0
@export var yaw : float 			= 0.0
@export var pitch : float 			= 0.0
@export var yawMutiplier : float 	= 0.13
@export var pitchMutiplier  : float = 0.3
@export var yawAccel : float 		= 15.0
@export var pitchAccel : float 		= 15.0

func _ready():
	Input.set_mouse_mode (Input.MOUSE_MODE_CAPTURED)
	
func _input (event):
	if event is InputEventMouseMotion and not playerRef.isDead:
		yaw += -event.relative.x * yawMutiplier
		pitch += -event.relative.y * pitchMutiplier

func _physics_process (delta):
	if playerRef.isDead:
		springDist.spring_length = 6.0
		pitchRef.rotation_degrees.x = lerp (pitchRef.rotation_degrees.x, -90.0, 0.7 * delta)
	else:
		pitch = clamp (pitch, PITCH_MIN, PITCH_MAX)
		yawRef.rotation_degrees.y = lerp (yawRef.rotation_degrees.y, yaw, yawAccel * delta)
		pitchRef.rotation_degrees.x = lerp (pitchRef.rotation_degrees.x, pitch, pitchAccel * delta)
