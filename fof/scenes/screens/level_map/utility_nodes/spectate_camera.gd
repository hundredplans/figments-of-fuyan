extends Camera3D

@export var LOOK_AT_HEIGHT: float = 1.0
@export var CAMERA_RADIUS: float = 1.4
@export var CAMERA_HEIGHT: Dictionary = {
	"Spawn": 2,
	"Unit": 3.2,
}
@export var CAMERA_ROTATION_SPEED: float = 3.0

var Units: UnitsGD
var Tiles: TilesGD

var central_point: Vector3
func on_camera_start_spectate(pos: Vector3, type: String) -> void:
	central_point = pos
	central_point.y += LOOK_AT_HEIGHT
	position = Vector3(pos.x, pos.y + CAMERA_HEIGHT[type], pos.z)
	on_set_camera_point_along_circle(0)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	elif Input.is_action_just_released(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		on_set_camera_point_along_circle((event.relative.x / 10000) * CAMERA_ROTATION_SPEED)

var total_progress: float = 0
func on_set_camera_point_along_circle(progress: float) -> void:
	total_progress = clampf(total_progress + progress, 0.0, 1.0)
	if total_progress <= 0.0: total_progress = 1.0
	elif total_progress >= 1.0: total_progress = 0.0
	
	position.x = (cos(2 * PI * total_progress) * CAMERA_RADIUS) + central_point.x
	position.z = (sin(2 * PI * total_progress) * CAMERA_RADIUS) + central_point.z
	look_at(central_point)
	
var spectate_type: String
var spectate_id: int = 0
func on_spectate(type: String = "Unit", id: int = 0) -> void:
	spectate_type = type
	spectate_id = id
	match type:
		"Spawn":
			var spawn_tiles: Array = Tiles.on_is_type_get_tiles("Spawn", "obj")
			
			if spectate_id == spawn_tiles.size(): spectate_id = 0
			elif spectate_id < 0: spectate_id = spawn_tiles.size() - 1
			
			on_camera_start_spectate(spawn_tiles[spectate_id].position, type)
		"Unit":
			var units: Array = Units.on_units(0, "Ally")
			
			if spectate_id == units.size(): spectate_id = 0
			elif spectate_id < 0: spectate_id = units.size() - 1
			
			on_camera_start_spectate(units[spectate_id].position, type)

func on_select_spectate_camera_direction(i: int) -> void:
	spectate_id += i
	on_spectate(spectate_type, spectate_id)
