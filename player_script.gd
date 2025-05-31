extends CharacterBody3D

var direction : Vector3 	      = Vector3.FORWARD
@export var speed : float 		  = 6.8
@export var accel : float 		  = 10.0
@export var gravity : float 	  = 80
@export var angularAccel : float  = 7
@export var maxJumpHeight : float = 4.5 

@onready var cameraRotation = $CameraPivotPoint/CameraYaw.global_transform.basis.get_euler().y

			
func _physics_process (delta):
	if Input.is_action_pressed("mJump") and is_on_floor():
		velocity.y = sqrt (maxJumpHeight * 2 * gravity)
		
	if (Input.is_action_pressed("mForward") ||
		Input.is_action_pressed("mBack")    ||
		Input.is_action_pressed("mLeft") 	||
		Input.is_action_pressed("mRight")): 
			
		cameraRotation = $CameraPivotPoint/CameraYaw.global_transform.basis.get_euler().y
			
		direction = Vector3 (Input.get_action_strength ("mRight") - 
							 Input.get_action_strength ("mLeft"), 
							 0,
							 Input.get_action_strength ("mBack") -
							 Input.get_action_strength ("mForward"))\
							.rotated(Vector3.UP, cameraRotation)
		
		velocity.x = lerp (velocity.x, direction.x * speed, delta * accel)
		velocity.z = lerp (velocity.z, direction.z * speed, delta * accel)
		
		$Roborb.rotation.y = lerp_angle ($Roborb.rotation.y, 
										 atan2 (direction.x, direction.z), 
										 delta * angularAccel)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	velocity.y -= gravity * delta	
	move_and_slide()
