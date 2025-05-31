class_name BatteryPickup extends Area3D

# Gives your broom Battery Power!

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	$Battery2.rotate_y(1.0 * delta)
	
func _on_body_entered(body: Node3D) -> void:
	body.get_battery()
	queue_free()
