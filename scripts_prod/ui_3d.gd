@tool
class_name UI3D extends Marker3D


@onready var ui_battery: Node3D = $UIBattery
@onready var chargeMeter: MeshInstance3D = $UIBattery/MeshInstance3D


@export var mario_star: bool
@export var charge := 100.0 : set = _set_charge

const MIN_METER_WIDTH = 0.05
const MAX_METER_WIDTH = 1.65

var battery_original_position: Vector3
var tween: Tween

signal ran_out_charge

func _ready() -> void:
	battery_original_position = ui_battery.position

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or (is_instance_valid(tween) and tween.is_running()):
		return

	if mario_star and charge > 0.0:
		charge -= delta * 15.0
		ui_battery.position.y = battery_original_position.y + (cos(charge * 3.0) * 0.05 * (charge / 100.0))
		if charge <= 0.0:
			ran_out_charge.emit()
	else:
		ui_battery.position = ui_battery.position.lerp(battery_original_position, 15.0 * delta)
	
func _set_charge(value: float) -> void:
	charge = clampf(value, 0.0, 100.0)
	if not is_inside_tree():
		await ready
	var f = charge / 100.0
	chargeMeter.get_surface_override_material(0).albedo_color = Color.RED.lerp(Color.GREEN, f)
	chargeMeter.mesh.size.x = lerp(MIN_METER_WIDTH, MAX_METER_WIDTH, f)
	chargeMeter.position.x = lerp(-0.8, 0.0, f)

func charge_up() -> void:
	tween = create_tween()
	tween.tween_property(self, "charge", 100.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
