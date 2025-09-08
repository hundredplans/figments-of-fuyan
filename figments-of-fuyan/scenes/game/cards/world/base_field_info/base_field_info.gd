class_name BaseFieldInfo extends Node3D

@export_group("Base Field Info")
@onready var SpeedFloatingStatSpot: Node3D = %SpeedFloatingStatSpot
@export var SpeedDefaultPacked: PackedScene
@export var speed_model_script: GDScript
@export var speed_material: Material
@export var speed_material_no_dt: Material
@export_group("")

const SPEED_MODEL_TILT: float = 7.5
const SPEED_MODEL_GREY_TIME: float = 0.25
const SPEED_MODEL_DESTROY_TIME: float = 0.5
const SPEED_MODEL_CREATE_TIME: float = 0.5
const SPEED_MODEL_MOVE_SPEED: float = 0.25

const PASSED_MAX_GREY: float = 0.2
const REGULAR_MAX_GREY: float = 0.5
const BRIGHTNESS_MAX: float = 2.0

var Card: CardGD
var depth_test_state: bool
var to_be_destroyed_models: Array = []
var is_spectated: bool = false

func setInfo(_Card: CardGD) -> void:
	Card = _Card
	onResetStats(true)

func setDepthTest(state: bool, override: bool = false) -> void:
	if state == depth_test_state or override: return
	depth_test_state = state
	var _speed_material: Material = speed_material if !depth_test_state else speed_material_no_dt
	for AvailableSpeedModel: Node3D in getAvailableSpeedModels():
		var MeshInst: MeshInstance3D = AvailableSpeedModel.get_child(0)
		MeshInst.set_surface_override_material(0, _speed_material)
		
func getSpeedModelCount() -> int:
	return SpeedFloatingStatSpot.get_child_count() - to_be_destroyed_models.size()

func getAvailableSpeedModels() -> Array:
	return SpeedFloatingStatSpot.get_children().filter(func(x: Node3D): return x not in to_be_destroyed_models)
	
func setSpeedModelMaterial(SpeedModel: Node3D, index: int, instant: bool = false) -> void:
	var mesh_inst: MeshInstance3D = SpeedModel.get_child(0)
	var time_value: float = getSpeedModelTimeValue(index)
	
	if time_value != mesh_inst.get_instance_shader_parameter("time_value"):
		if instant:
			mesh_inst.set_instance_shader_parameter("time_value", time_value)
		else:
			var time_inverse: float = abs(time_value - 1)
			mesh_inst.set_instance_shader_parameter("time_value", time_inverse)
			var tween := create_tween()
			tween.tween_method(setTimeValueShaderParameter.bind(mesh_inst),\
				time_inverse, time_value, SPEED_MODEL_GREY_TIME)
	
	var max_grey_value: float = getSpeedModelMaxGrey(index)
	var current_max_grey_value: float = mesh_inst.get_instance_shader_parameter("max_grey")
	if max_grey_value != current_max_grey_value:
		if instant:
			mesh_inst.set_instance_shader_parameter("max_grey", max_grey_value)
		else:
			var tween := create_tween()
			tween.tween_method(setMaxGreyShaderParameter.bind(mesh_inst),\
				current_max_grey_value, max_grey_value, SPEED_MODEL_GREY_TIME)
	
	var brightness: float = getSpeedModelBrightness()
	var current_brightness: float = mesh_inst.get_instance_shader_parameter("brightness")
	if current_brightness != brightness:
		if instant:
			mesh_inst.set_instance_shader_parameter("brightness", brightness)
		else:
			var tween := create_tween()
			tween.tween_method(setBrightnessShaderParameter.bind(mesh_inst),\
				current_brightness, brightness, SPEED_MODEL_GREY_TIME)
				
func setBrightnessShaderParameter(value: float, mesh_inst: MeshInstance3D) -> void:
	mesh_inst.set_instance_shader_parameter("brightness", value)
	
func setMaxGreyShaderParameter(value: float, mesh_inst: MeshInstance3D) -> void:
	mesh_inst.set_instance_shader_parameter("max_grey", value)
	
func setTimeValueShaderParameter(value: float, mesh_inst: MeshInstance3D) -> void:
	mesh_inst.set_instance_shader_parameter("time_value", value)
				
func getSpeedModel() -> Node3D:
	return SpeedDefaultPacked.instantiate()

func getSpeedModelPosition(index: int, count: int = getSpeedModelCount()) -> Vector2:
	match count:
		1: return Vector2.ZERO
		2: return [Vector2(-0.15, 0), Vector2(0.15, 0)][index]
		3: return [Vector2(-0.3, 0), Vector2(0, 0.05), Vector2(0.3, 0)][index]
		4: return [Vector2(-0.45, 0.05), Vector2(-0.15, 0), Vector2(0.15, 0.05), Vector2(0.45, 0)][index]
		5: return [Vector2(-0.6, 0.05), Vector2(-0.3, 0), Vector2(0, 0.05),
			Vector2(0.3, 0), Vector2(0.6, 0.05)][index]
	assert(false)
	return Vector2.ZERO

func onCreateMaxSpeedStat(value: int, above_green_value: int, below_red_value: int) -> void:
	var speed_model_amount: int = getSpeedModelCount()
	if value > speed_model_amount: onCreateMaxSpeedModels(value, speed_model_amount)
	elif value < speed_model_amount: onDestroyMaxSpeedModels(value, speed_model_amount)
			
func onDestroyMaxSpeedModels(value: int, speed_model_amount: int) -> void:
	var destroyed_models: Array = []
	for i: int in range(speed_model_amount - value):
		var child_index: int = getSpeedModelCount() - 1 - i
		var RightSpeedModel: Node3D = SpeedFloatingStatSpot.get_child(child_index)
		if RightSpeedModel == null: continue # Happens if it's in to be destroyed models
		
		to_be_destroyed_models.append(RightSpeedModel)
		destroyed_models.append(RightSpeedModel)
		var tween := create_tween()
		tween.tween_property(RightSpeedModel, "rotation:y", 2 * PI, SPEED_MODEL_DESTROY_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		
		var ntween := create_tween()
		ntween.tween_property(RightSpeedModel, "scale", -Vector3(0.99, 0.99, 0.99), SPEED_MODEL_DESTROY_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
	var i: int = 0
	for SpeedModel: Node3D in getAvailableSpeedModels():
		var tween := create_tween()
		var speed_model_position: Vector2 = getSpeedModelPosition(i, value)
		var new_speed_model_position := Vector3(speed_model_position.x, speed_model_position.y, 0)
		tween.tween_property(SpeedModel, "position", new_speed_model_position - SpeedModel.position, SPEED_MODEL_MOVE_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		i += 1
			
	await get_tree().create_timer(SPEED_MODEL_DESTROY_TIME).timeout
	for SpeedModel: Node3D in destroyed_models:
		SpeedModel.queue_free()
		to_be_destroyed_models.erase(SpeedModel)
		
func onCreateMaxSpeedModels(value: int, speed_model_amount: int) -> void:
	var i: int = 0
	for AvailableSpeedModel: Node3D in getAvailableSpeedModels():
		var tween := create_tween()
		var speed_model_position: Vector2 = getSpeedModelPosition(i, value)
		var new_speed_model_position := Vector3(speed_model_position.x, speed_model_position.y, 0)
		tween.tween_property(AvailableSpeedModel, "position", new_speed_model_position - AvailableSpeedModel.position, SPEED_MODEL_MOVE_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		
		i += 1
	
	for j: int in range(value - speed_model_amount):
		var SpeedModel: Node3D = getSpeedModel()
		SpeedModel.script = speed_model_script
		SpeedModel.rotation_degrees.z = SPEED_MODEL_TILT
		SpeedFloatingStatSpot.add_child(SpeedModel)
		
		var index: int = getSpeedModelCount() - 1
		var mesh_inst: MeshInstance3D = SpeedModel.get_child(0)
		mesh_inst.set_surface_override_material(0, speed_material)
		mesh_inst.set_instance_shader_parameter("time_value", 0.0)
		mesh_inst.set_instance_shader_parameter("max_grey", 0.0)
		mesh_inst.set_instance_shader_parameter("brightness", 1.0)
		
		setSpeedModelMaterial(SpeedModel, index, true)
		
		var speed_model_position: Vector2 = getSpeedModelPosition(index, value)
		SpeedModel.position = Vector3(speed_model_position.x, speed_model_position.y, 0)
		SpeedModel.scale = Vector3(0.01, 0.01, 0.01)
		
		var tween := create_tween()
		tween.tween_property(SpeedModel, "rotation:y", 2 * PI, SPEED_MODEL_CREATE_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		
		var ntween := create_tween()
		ntween.tween_property(SpeedModel, "scale", Vector3(0.99, 0.99, 0.99), SPEED_MODEL_CREATE_TIME)\
			.as_relative().set_trans(Tween.TRANS_SINE)
	
func getSpeedModelMaxGrey(index: int) -> float:
	if Card.getTurnState() == Game.TurnStates.PASSED: return PASSED_MAX_GREY
	if isSpeedUsed(index): return REGULAR_MAX_GREY
	return 0.0
	
func getSpeedModelTimeValue(index: int) -> float:
	if Card.getTurnState() == Game.TurnStates.PASSED: return 1.0
	if isSpeedUsed(index): return 1.0
	return 0.0
	
func getSpeedModelBrightness() -> float:
	return BRIGHTNESS_MAX if (Card.getTurnState() == Game.TurnStates.ACTIVE) else 1.0
	
func isSpeedUsed(index: int) -> bool:
	return Card.speed < (index + 1)
	
func onUpdateSpeedStat(speed: int, instant: bool = false) -> void:
	var max_speed: int = Card.max_speed
	var speed_models: Array = SpeedFloatingStatSpot.get_children()
	for i: int in range(max_speed):
		if i >= speed_models.size(): continue
		if speed_models[i] in to_be_destroyed_models: continue
		
		var SpeedModel: Node3D = speed_models[i]
		setSpeedModelMaterial(SpeedModel, i, instant)

func onUpdateStat(type: Game.Stats, value: int, difference: int, play_animation: bool = false, show_particles: bool = true) -> void:
	if type not in [Game.Stats.SPEED, Game.Stats.MAX_SPEED]: return
	onCreateSpecificStat(type, value)

func onCreateSpecificStat(type: Game.Stats, value: int) -> void:
	var stat_datastore: StatsDatastore = Card.getStatsFromInfo()
	match type:
		Game.Stats.MAX_SPEED: onCreateMaxSpeedStat(value, stat_datastore.speed, Card.speed)
		Game.Stats.SPEED: onUpdateSpeedStat(value)

func onResetStats(override: bool = false) -> void:
	onResetDepthTest(override)
	onCreateFloatingNumbers()

func onResetDepthTest(override: bool = false) -> void:
	setDepthTest(is_spectated, override)
	
func onSpectated(state: bool) -> void:
	is_spectated = state
	onResetStats()
	
func onCreateFloatingNumbers() -> void:
	onCreateSpecificStat(Game.Stats.MAX_SPEED, Card.max_speed)
	onCreateSpecificStat(Game.Stats.SPEED, Card.speed)
