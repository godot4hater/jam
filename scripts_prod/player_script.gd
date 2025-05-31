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

var isHoldingItem : bool                    = false
var isSlow : bool                           = false
@onready var cameraRotation                 = $CameraPivotPoint/CameraYaw.global_transform.basis.get_euler().y
@onready var objHolderRef                   = $Roborb/ObjectHolderNode
@onready var broom: Broom                   = $Broom
@onready var remote_back: RemoteTransform3D = $Roborb/Armature/Skeleton3D/BackAttachment/RemoteBack
@onready var remote_hand: RemoteTransform3D = $Roborb/Armature/Skeleton3D/HandAttachment/RemoteHand
@onready var ui_3d: UI3D                    = $SubViewportContainer/SubViewport/UI3D
@onready var anim_player: AnimationPlayer   = $Roborb/AnimationPlayer
## This is the things you hold, not Roborbs body
var bodyRef : Node3D
var roborb_track_material: ShaderMaterial

func _ready() -> void:
	# Reset broom remotes
	broom.holstered = true
	remote_back.remote_path = remote_back.get_path_to(broom)
	remote_hand.remote_path = ""
	roborb_track_material = $Roborb/Armature/Skeleton3D/Cube.mesh.surface_get_material(1)

func _input (event):
	if event.is_action_pressed("mSlowToggle"):
		isSlow = !isSlow
		if isSlow:
			speed = speed / 4
			angularAccel = angularAccel / 4
		else:
			speed = MAX_SPEED
			angularAccel = MAX_ANG_ACCEL
			
	if event.is_action_pressed("CheatBroom"):
		broom.holstered = !broom.holstered
		remote_back.remote_path = remote_back.get_path_to(broom) if broom.holstered else ""
		remote_hand.remote_path =  "" if broom.holstered else remote_hand.get_path_to(broom)
			
func _physics_process (delta):
	if Input.is_action_pressed("mJump") and is_on_floor():
		velocity.y = sqrt (maxJumpHeight * 2 * gravity)
		
		
	var h_input = Input.get_vector("mLeft", "mRight", "mForward", "mBack")
	print(h_input)
	if h_input:	
		cameraRotation = $CameraPivotPoint/CameraYaw.global_transform.basis.get_euler().y	
		direction = Vector3(h_input.x, 0.0, h_input.y).rotated(Vector3.UP, cameraRotation)
		
		if broom.holstered:
			velocity.x = lerp (velocity.x, direction.x * speed, delta * accel)
			velocity.z = lerp (velocity.z, direction.z * speed, delta * accel)
		elif not broom.holstered:
			velocity.x = lerp(velocity.x, $Roborb.global_basis.z.x * 20.0, 5.0 * delta)
			velocity.z = lerp(velocity.z, $Roborb.global_basis.z.z * 20.0, 5.0 * delta)
			
		$Roborb.rotation.y = lerp_angle ($Roborb.rotation.y, 
										 atan2 (direction.x, direction.z), 
										 delta * angularAccel)
	else:
		if broom.holstered:
			velocity.x = lerp(velocity.x, 0.0, 10.0 * delta)
			velocity.z = lerp(velocity.z, 0.0, 10.0 * delta)
	
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
	
	var vel = Vector2(velocity.x, velocity.z).length()
	roborb_track_material.set_shader_parameter("speed", 1.0 if vel > 0.1 else 0.0)
	$Roborb/DustTrail1.amount_ratio = 0.5 if (vel > 0.1 and is_on_floor()) else 0.0
	$Roborb/DustTrail2.amount_ratio = 0.5 if (vel > 0.1 and is_on_floor()) else 0.0
	if not broom.holstered: anim_player.play("brushing")
	else:
		if vel > 0.5:
			anim_player.play("walk")
		elif vel > 5.0:
			anim_player.play("run")
		else:
			anim_player.play("idle")

func ThrowItem (strength : Vector3):
		isHoldingItem = false
		bodyRef.linear_velocity = strength
		bodyRef.set_collision_layer_value (1, true)
		bodyRef.set_collision_layer_value (4, false)
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group ("TrashPile") && isHoldingItem == false:
		bodyRef = body
		isHoldingItem = true

func get_battery() -> void:
	ui_3d.charge_up()
	#if batteryPower == 3:
	broom.holstered = false
	remote_back.remote_path = remote_back.get_path_to(broom) if broom.holstered else ""
	remote_hand.remote_path =  "" if broom.holstered else remote_hand.get_path_to(broom)


func _on_ui_3d_ran_out_charge() -> void:
	broom.holstered = true
	remote_back.remote_path = remote_back.get_path_to(broom) if broom.holstered else ""
	remote_hand.remote_path =  "" if broom.holstered else remote_hand.get_path_to(broom)
