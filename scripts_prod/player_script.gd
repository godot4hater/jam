extends CharacterBody3D

var direction : Vector3 	      			= Vector3.FORWARD
const MAX_SPEED : float     				= 12.0
const MAX_ANG_ACCEL : float 				= 3.5
const MAX_JUMP_HEIGHT : float               = 4.5
const DEBUFF_JUMP_HEIGHT : float			= 1.25
const SLOW_FACTOR : float                   = 4.0
@export var gravity : float 				= 80.0
@export var speed : float 					= 12.0
@export var accel : float 					= 10.0
@export var angularAccel : float  			= 3.5
@export var curJumpHeight : float 			= 4.5 
@export var throwStrength : float           = 8.25
@export_enum("Neutral", "Excited", "Frazzled") var expression := "Neutral" :
	set(new):
		expression = new
		match expression:
			"Neutral":
				roborb_face_material.set_shader_parameter("face_coord", Vector2(0.0, 0.0))
			"Excited":
				roborb_face_material.set_shader_parameter("face_coord", Vector2(0.0, 0.5))
			"Frazzled":
				roborb_face_material.set_shader_parameter("face_coord", Vector2(0.5, 0.5))

# player states
var isHoldingItem : bool                    = false
var isSlow : bool                           = false
var isDead : bool                           = false
var inLava : bool                           = false
signal emitBroomPickupTrash 

# annoying hard references
@onready var cameraRotation                 = $CameraPivotPoint/CameraYaw.global_transform.basis.get_euler().y
@onready var objHolderRef                   = $Roborb/ObjectHolderNode
@onready var broom: Broom                   = $Broom
@onready var remote_back: RemoteTransform3D = $Roborb/Armature/Skeleton3D/BackAttachment/RemoteBack
@onready var remote_hand: RemoteTransform3D = $Roborb/Armature/Skeleton3D/HandAttachment/RemoteHand
@onready var ui_3d: UI3D                    = $SubViewportContainer/SubViewport/UI3D
@onready var anim_player : AnimationPlayer  = $Roborb/AnimationPlayer
@onready var timerLabelRef : Label          = $SubViewportContainer/SubViewport/timeLeftLabel
@onready var winLabelRef : Label            = $SubViewportContainer/SubViewport/winLabel
@onready var diedLabelRef : Label           = $SubViewportContainer/SubViewport/diedLabel
@onready var countLabelRef : Label          = $SubViewportContainer/SubViewport/countLabel
@onready var moveSndP : AudioStreamPlayer3D = $MoveSound
@onready var actionSndP: AudioStreamPlayer3D= $ActionSFX
@onready var lavaRef                        = get_tree().get_root().get_node ("testlvl/Lava/AreaSlow")
@onready var killboxRef                     = get_tree().get_root().get_node ("testlvl/Lava/AreaKill")
@onready var gameLoopRef                    = get_tree().get_root().get_node ("testlvl")

var idlesnd   = preload ("res://assets/sounds/roboIdle_snd.wav")
var jumpsnd   = preload ("res://assets/sounds/roboJump_snd.wav")
var movesnd   = preload ("res://assets/sounds/roboMove_snd.wav")
var dropsnd   = preload ("res://assets/sounds/roboDrop_snd.wav")
var sprintsnd = preload ("res://assets/sounds/brushMode_snd.wav")
var throwsnd  = preload ("res://assets/sounds/roboThrow_snd.wav")

## This is the things you hold, not Roborbs body
var bodyRef : Node3D
var roborb_track_material: ShaderMaterial
var roborb_face_material: ShaderMaterial

func _ready() -> void:
	if gMode.endless:
		countLabelRef.text = "0"
		
	# Reset broom remotes
	broom.holstered = true
	remote_back.remote_path = remote_back.get_path_to(broom)
	remote_hand.remote_path = ""
	roborb_track_material = $Roborb/Armature/Skeleton3D/Cube.mesh.surface_get_material(1)
	roborb_face_material = $Roborb/Armature/Skeleton3D/Cube.mesh.surface_get_material(2)

func _input (event):
	if event.is_action_pressed ("mSlowToggle") and not inLava:
		isSlow = !isSlow
		
		if isSlow:
			speed = speed / SLOW_FACTOR
			angularAccel = angularAccel / SLOW_FACTOR
		else:
			speed = MAX_SPEED
			angularAccel = MAX_ANG_ACCEL
			
	#if event.is_action_pressed ("mJump") and not broom.holstered:
	#	actionSndP.stream = jumpsnd
	#	actionSndP.play()
	#	velocity.y = sqrt (curJumpHeight * 1.5 * gravity)
				
	if event.is_action_pressed ("CheatBroom"):
		broom.holstered = !broom.holstered
		remote_back.remote_path = remote_back.get_path_to(broom) if broom.holstered else NodePath()
		remote_hand.remote_path =  NodePath() if broom.holstered else remote_hand.get_path_to(broom)
		expression = ["Neutral", "Excited", "Frazzled"].pick_random()
	#if event.is_action_pressed ("QuitBtn"):
	#	get_tree().quit()
			
func _physics_process (delta):
	if isDead:
		return 
		
	var h_input = Input.get_vector("mLeft", "mRight", "mForward", "mBack")
	
	if h_input:	
		cameraRotation = $CameraPivotPoint/CameraYaw.global_transform.basis.get_euler().y	
		direction = Vector3(h_input.x, 0.0, h_input.y).rotated(Vector3.UP, cameraRotation)
		
		if broom.holstered:
			velocity.x = lerp (velocity.x, direction.x * speed, delta * accel)
			velocity.z = lerp (velocity.z, direction.z * speed, delta * accel)
		elif not broom.holstered:
			#velocity.x = lerp(velocity.x, $Roborb.global_basis.z.x * 20.0, 5.0 * delta)
			#velocity.z = lerp(velocity.z, $Roborb.global_basis.z.z * 20.0, 5.0 * delta)
			# nerfed
			velocity.x = lerp (velocity.x, direction.x * 21.0, delta * 5.0)
			velocity.z = lerp (velocity.z, direction.z * 21.0, delta * 5.0)
			
		$Roborb.rotation.y = lerp_angle ($Roborb.rotation.y, 
										 atan2 (direction.x, direction.z), 
										 delta * angularAccel)
	else:
		if broom.holstered:
			velocity.x = lerp(velocity.x, 0.0, 10.0 * delta)
			velocity.z = lerp(velocity.z, 0.0, 10.0 * delta)
	
	if isHoldingItem and is_instance_valid (bodyRef):
		bodyRef.global_position = objHolderRef.global_position
		bodyRef.global_rotation = objHolderRef.global_rotation
		bodyRef.set_collision_layer_value (1, false)
		bodyRef.set_collision_layer_value (4, true)
	
	if Input.is_action_pressed("Fire") and isHoldingItem and is_instance_valid (bodyRef):
		actionSndP.stream = throwsnd
		actionSndP.play()
		ThrowItem ($Roborb.get_global_transform().basis.z * 10)
		bodyRef.linear_velocity.y = throwStrength
		bodyRef = null
	
	if Input.is_action_pressed("Release") and isHoldingItem and is_instance_valid (bodyRef):
		actionSndP.stream = dropsnd
		actionSndP.play()
		ThrowItem (Vector3 (0.1, 1.0, 0.1))
		bodyRef = null
		
	if Input.is_action_pressed("mJump") and is_on_floor():
		actionSndP.stream = jumpsnd
		actionSndP.play()
		velocity.y = sqrt (curJumpHeight * 2 * gravity)
	
	velocity.y -= gravity * delta
	#########################
	# all movement adjustments must be done before calling move & slide
	# so essentially this is the movement final statement
	#########################
	move_and_slide()
	
	var vel = Vector2(velocity.x, velocity.z).length()
	roborb_track_material.set_shader_parameter("speed", 1.0 if vel > 0.1 else 0.0)
	$Roborb/DustTrail1.amount_ratio = 0.5 if (vel > 0.1 and is_on_floor()) else 0.0
	$Roborb/DustTrail2.amount_ratio = 0.5 if (vel > 0.1 and is_on_floor()) else 0.0
	
	if not broom.holstered: 
		anim_player.play("brushing")
		
		if !moveSndP.is_playing():
			moveSndP.stream = sprintsnd
			moveSndP.play()
			
		if isHoldingItem:
			emitBroomPickupTrash.emit()
			isHoldingItem = false
			bodyRef.queue_free()
			bodyRef = null
	else:
		moveSndP.stop()
		
		if vel < 0.1:
			anim_player.play("idle")
		elif vel < 5.0:
			anim_player.play("walk")
		elif vel >= 5.0 and not isHoldingItem:
			anim_player.play("run")
	
	if not is_instance_valid (bodyRef):
		isHoldingItem = false

func ThrowItem (strength : Vector3):
		isHoldingItem = false
		bodyRef.linear_velocity = strength
		bodyRef.set_collision_layer_value (1, true)
		bodyRef.set_collision_layer_value (4, false)
		
func _on_area_3d_body_entered (body: Node3D) -> void:
	if body.is_in_group ("TrashPile") && !isHoldingItem:
		bodyRef = body
		isHoldingItem = true
		anim_player.play ("walk")
	elif body.is_in_group ("TrashPile") && !isHoldingItem && !broom.holstered:
		body.queue_free()
		bodyRef = null
		isHoldingItem = false

func get_battery() -> void:
	expression = "Excited"
	ui_3d.charge_up()
	#if batteryPower == 3:
	broom.holstered = false
	remote_back.remote_path = remote_back.get_path_to(broom) if broom.holstered else NodePath()
	remote_hand.remote_path =  NodePath() if broom.holstered else remote_hand.get_path_to(broom)

# message nightmare, godont is insane

func _on_ui_3d_ran_out_charge() -> void:
	expression = "Neutral"
	broom.holstered = true
	remote_back.remote_path = remote_back.get_path_to(broom) if broom.holstered else NodePath()
	remote_hand.remote_path =  NodePath() if broom.holstered else remote_hand.get_path_to(broom)

func _on_testlvl_put_time_in_players_label (timeOutput: String) -> void:
	timerLabelRef.text = timeOutput

# this is dumb, there has to be a better way of doing this
# i need to refactor it so theres only mono chute and all the nodes just share the same message
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area == lavaRef:
		expression = "Frazzled"
		inLava = true
		speed = 4.0
		curJumpHeight = DEBUFF_JUMP_HEIGHT
	
	if area == killboxRef:
		isDead = true
		diedLabelRef.visible = true
		
		var timerD: Timer = Timer.new()
		timerD.wait_time = 4
		timerD.one_shot = false
		timerD.autostart = true
		timerD.timeout.connect (_on_timer_timeout2)
		add_child (timerD)

func _on_timer_timeout2() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes_levels/main_menu.tscn")
		
func _on_area_3d_area_exited(area: Area3D) -> void:
	if area == lavaRef:
		if broom.holstered: expression = "Neutral"
		inLava = false
		speed = MAX_SPEED 
		curJumpHeight = MAX_JUMP_HEIGHT

func _on_area_3d_reduce_trash_counter() -> void:
	if gMode.endless:
		countLabelRef.text = str (gameLoopRef.trashCollected)
	else:
		countLabelRef.text = str (gameLoopRef.TRASH_AMOUNT_WIN_CON - gameLoopRef.trashCollected)

func _on_area_3d_player_wins() -> void:
	winLabelRef.visible = true


func _on_neutral_expression_timer_timeout() -> void:
	if expression == "Neutral":
		var x = roborb_face_material.get_shader_parameter("face_coord").x
		roborb_face_material.set_shader_parameter("face_coord", Vector2(x + 0.5, 0.0))
