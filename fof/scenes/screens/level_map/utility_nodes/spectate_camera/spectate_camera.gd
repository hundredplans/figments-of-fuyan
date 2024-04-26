extends Node3D

signal mouse_in_ui

@onready var Camera = %Camera3D

@export var LOOK_AT_UNIT_HEIGHT_MULTIPLIER: float = 0.8
@export var CAMERA_UNIT_HEIGHT_MULTIPLIER: float = 1.2

@export var CAMERA_RADIUS: float = 2.0 * (1 + (0.01 * Settings.camera_distance))
@export var CAMERA_ROTATION_SPEED: float = 3.0

@export var SPAWN_CAMERA_CENTRAL_POINT_HEIGHT: float = 2.4
@export var SPAWN_CAMERA_LOOK_AT_HEIGHT: float = 1.7

var spectates: Dictionary = {
	"Spawn": {},
	"Enemy": {},
	"Ally": {},
}

var Vision: VisionGD
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var Units: UnitsGD
var Tiles: TilesGD

var spectate_type: String

var central_point: Vector3
var total_progress := Vector2.ZERO
var Y_SPHERE_BLOCK: float = 0.3

func onGetActiveSpectateVariant() -> Dictionary:
	if !spectate_type.is_empty():
		if spectate_type != "Spawn":
			for key in spectates[spectate_type].keys():
				if spectates[spectate_type][key].is_active:
					return spectates[spectate_type][key]
		else:
			for key in spectates.Spawn.keys():
				if spectates.Spawn[key].is_active:
					if Units.unit_by_tile_bool(spectates.Spawn[key].object):
						spectates.Spawn[key].is_active = false
						return onFindSpawnAlternativeTile()
					return spectates.Spawn[key]
			return onFindSpawnAlternativeTile()
	return {}
	
func onFindSpawnAlternativeTile() -> Dictionary:
	for key in spectates.Spawn.keys():
		if !Units.unit_by_tile_bool(spectates.Spawn[key].object):
			spectates.Spawn[key].is_active = true
			return spectates.Spawn[key]
	return {}
func onCameraStartSpectate(spectate_info: Dictionary) -> void:
	central_point = spectate_info.object.global_position
	central_point.y += spectate_info.central_point
	position = Vector3(central_point.x, central_point.y + spectate_info.look_at, central_point.z)
	setCameraPointAlongCircle()
func setCameraPointAlongCircle(progress: Vector2 = Vector2.ZERO) -> void:
	if progress != Vector2.ZERO:
		total_progress.x = clampf(total_progress.x + progress.x, 0, 1)
		if total_progress.x <= 0: total_progress.x = 1
		elif total_progress.x >= 1: total_progress.x = 0
		
		total_progress.y = clampf(total_progress.y + progress.y, -Y_SPHERE_BLOCK, Y_SPHERE_BLOCK)
	
	var theta: float = total_progress.x * 2 * PI
	var phi: float = total_progress.y * PI

	position.x = cos(phi) * cos(theta) * CAMERA_RADIUS + central_point.x
	position.y = sin(phi) * CAMERA_RADIUS + central_point.y
	position.z = cos(phi) * sin(theta) * CAMERA_RADIUS + central_point.z
	look_at(central_point)
func onStartPhaseStart() -> void:
	var i: int = 0
	for Tile in Tiles.on_is_type_get_tiles("Spawn", "obj"):
		spectates.Spawn[Tile.get_instance_id()] = {
			"progress": Vector2.ZERO,
			"is_active": i == 0,
			"look_at": SPAWN_CAMERA_LOOK_AT_HEIGHT,
			"central_point": SPAWN_CAMERA_CENTRAL_POINT_HEIGHT,
			"object": Tile,
		}
		i+= 1
	onSpectate("Spawn")
	
func onSpectate(type: Variant) -> void:
	var spectate_info: Dictionary = onGetActiveSpectateVariant()
	if !spectate_info.is_empty(): spectate_info.progress = total_progress
	
	if type is int: onSpectateDirection(spectate_info, spectate_type, type)
	elif type is String: onSpectateNewType(spectate_info, type, spectate_type)
	elif type is UnitGD or type is TileGD: onSpectateObject(type, spectate_info, spectate_type)
			
func onSpectateObject(Obj: Variant, _spectate_info: Dictionary, _spectate_type: String) -> void:
	spectate_type = ("Ally" if Obj.team == 0 else "Enemy") if Obj is UnitGD else "Spawn"
	var spectate_info: Dictionary = spectates[spectate_type][Obj.get_instance_id()]
	
	if spectate_info != _spectate_info:
		onClearIsActive(spectate_info, spectate_type)
		onCameraStartSpectate(spectate_info)
		onUnitSpectated(spectate_info, _spectate_info, _spectate_type)
	
func onSpectateNewType(_spectate_info: Dictionary, _spectate_type: String, old_spectate_type: String) -> void:
	if spectate_type != _spectate_type:
		spectate_type = _spectate_type
		var spectate_info: Dictionary = onGetActiveSpectateVariant()
		if !spectate_info.is_empty():
			total_progress = spectate_info.progress
			onCameraStartSpectate(spectate_info)
			onUnitSpectated( spectate_info, _spectate_info, old_spectate_type)
		else: spectate_type = old_spectate_type
		
func onSpectateDirection(_spectate_info: Dictionary, _spectate_type: String, direction: int) -> void:
	if !_spectate_info.is_empty():
		var spectate_type_keys: Array = getSpectateTypeKeys()
		var new_index: int = 0
		var index: int = -1
		
		_spectate_info.is_active = false
		index = spectate_type_keys.map(func(x: Dictionary): return x.object.get_instance_id()).find(_spectate_info.object.get_instance_id())
		var max_size: int = spectate_type_keys.size()
		
		if index == -1: new_index = 0
		elif index == 0 and direction == -1: new_index = max_size - 1
		elif index == max_size - 1 and direction == 1: new_index = 0
		else: new_index = index + direction
		
		var spectate_info: Dictionary = spectate_type_keys[new_index]
		
		if spectate_info != _spectate_info:
			spectate_info.is_active = true
			total_progress = spectate_info.progress
			
			onCameraStartSpectate(spectate_info)
			onUnitSpectated(spectate_info, _spectate_info, spectate_type)
		
func onClearIsActive(spectate_info: Dictionary, type: String) -> void:
	for _spectate_info in spectates[type].values():
		_spectate_info.is_active = false
	spectate_info.is_active = true
		
func getSpectateTypeKeys() -> Array:
	if spectate_type == "Spawn":
		var unoccupied_spawn_dicts: Array = []
		for spawn_dict in spectates.Spawn.values():
			if !Units.unit_by_tile_bool(spawn_dict.object):
				unoccupied_spawn_dicts.append(spawn_dict)
		return unoccupied_spawn_dicts
	return spectates[spectate_type].values()
		
func onUnitSpectated(spectate_info: Dictionary, _spectate_info: Dictionary, _spectate_type: String) -> void:
	if spectate_type in ["Ally", "Enemy"]:
		spectate_info.object.on_spectated_in_player_phase(true)
		if Vision.vision_mode == 1: Vision.on_recalculate_vision(spectate_info.object)
		Units.onSpectatedInPlayerPhase(spectate_info.object)
		
	if _spectate_type in ["Ally", "Enemy"]:
		Units.PlayerManager._on_unit_deselected(Units.PlayerManager.UnitSelected)
		if !_spectate_info.is_empty(): _spectate_info.object.on_spectated_in_player_phase(false)
		
func onPlayerPhaseStart() -> void:
	onEndTrackUnit()
	onSpectate("Ally")
func onPlayerEndTurnPhaseStart() -> void:
	onEndTrackUnit()
	onSpectate("Ally")
func onHandPhaseStart() -> void:
	onEndTrackUnit()
	onSpectate("Ally")
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().update_mouse_cursor_state()
		mouse_in_ui.emit(true)
		
	elif Input.is_action_just_released(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_in_ui.emit(false)
			
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		setCameraPointAlongCircle((event.relative / 10000) * CAMERA_ROTATION_SPEED)

var track_unit_info: Dictionary
func onStartTrackUnit(Unit: UnitGD) -> void:
	track_unit_info = spectates["Ally" if Unit.team == 0 else "Enemy"][Unit.get_instance_id()].duplicate()
	onSpectate(Unit)
func onEndTrackUnit() -> void:
	track_unit_info = {}
func onTrackUnit() -> void:
	onCameraStartSpectate(track_unit_info)
func _process(_delta) -> void:
	if !track_unit_info.is_empty(): onTrackUnit()

func onUnitAwakened(Unit: UnitGD) -> void:
	var team_spectate_type: String = "Ally" if Unit.team == 0 else "Enemy"
	spectates[team_spectate_type][Unit.get_instance_id()] = {
		"progress": Vector2.ZERO,
		"is_active": false,
		"look_at": Unit.height.top * CAMERA_UNIT_HEIGHT_MULTIPLIER,
		"central_point": Unit.height.top * LOOK_AT_UNIT_HEIGHT_MULTIPLIER,
		"object": Unit,
	}
func onDeathFinished(Unit: UnitGD) -> void:
	spectates["Ally" if Unit.team == 0 else "Enemy"].erase(Unit.get_instance_id())
	if !track_unit_info.is_empty() and track_unit_info.object == Unit: onEndTrackUnit()
	
func getSpectateUnit(team: Array = ["Ally"]) -> UnitGD:
	if spectate_type in team:
		var spectate_info: Dictionary = onGetActiveSpectateVariant()
		if !spectate_info.is_empty(): return spectate_info.object
	return null
