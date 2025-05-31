extends CharacterBody3D

var direction : Vector3 	      = Vector3.FORWARD
@export var MAX_SPEED : float     = 12.0
@export var MAX_ANG_ACCEL : float = 3.5
@export var speed : float 		  = 12.0
@export var accel : float 		  = 10.0
@export var gravity : float 	  = 80
@export var angularAccel : float  = 3.5
@export var maxJumpHeight : float = 4.5 
@export var throwStrength : float = 7.0

var isHoldingItem : bool    = false
var isSlow : bool           = false
@onready var cameraRotation = $CameraPivotPoint/CameraYaw.global_transform.basis.get_euler().y
@onready var objHolderRef   = $Roborb/ObjectHolderNode
var bodyRef : Node3D

func _input (event):
	if event.is_action_pressed("mSlowToggle"):
		isSlow = !isSlow
		if isSlow:
			speed = speed / 4
			angularAccel = angularAccel / 4
		else:
			speed = MAX_SPEED
			angularAccel = MAX_ANG_ACCEL
			
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
	
	if isHoldingItem:
		bodyRef.global_position = objHolderRef.global_position
		bodyRef.global_rotation = objHolderRef.global_rotation
		bodyRef.set_collision_layer_value (1, false)
		bodyRef.set_collision_layer_value (4, true)
	
	if Input.is_action_pressed("Fire") and isHoldingItem:
		ThrowItem ($Roborb.get_global_transform().basis.z * 10)
		bodyRef.linear_velocity.y = throwStrength
	
	if Input.is_action_pressed("Release") and isHoldingItem:
		ThrowItem (Vector3 (0.1, 1.0, 0.1))
		
	if Input.is_action_pressed("mJump") and is_on_floor():
		velocity.y = sqrt (maxJumpHeight * 2 * gravity)
	
	velocity.y -= gravity * delta	
	move_and_slide()

func ThrowItem (strength : Vector3):
		isHoldingItem = false
		bodyRef.linear_velocity = strength
		bodyRef.set_collision_layer_value (1, true)
		bodyRef.set_collision_layer_value (4, false)
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group ("TrashPile"):
		bodyRef = body
		isHoldingItem = true
