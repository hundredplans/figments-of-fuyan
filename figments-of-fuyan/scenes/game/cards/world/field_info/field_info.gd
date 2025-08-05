extends Node3D

#region Onreadies
@onready var FloatingStats: Node3D = %FloatingStats

@onready var AttackFloatingStatSpot: Node3D = %AttackFloatingStatSpot
@onready var HealthFloatingStatSpot: Node3D = %HealthFloatingStatSpot
@onready var SpeedFloatingStatSpot: Node3D = %SpeedFloatingStatSpot

@onready var AttackSpot: Node3D = %AttackSpot
@onready var HealthSpot: Node3D = %HealthSpot

@onready var Numbers: Node3D = %Numbers
@onready var IconsManager: Node3D = %IconsManager

@onready var ToolIcon: Sprite3D = %ToolIcon

@onready var NumbersParticleManager: Node3D = %NumbersParticleManager
#endregion

@export var number_to_model: Array[PackedScene]
@export_group("Materials")

@export var dark_green_with_outline_material: Material
@export var green_with_outline_material: Material
@export var red_with_outline_material: Material
@export var white_with_outline_material: Material
@export var pink_with_outline_material: Material
@export var orange_with_outline_material: Material

@export var green_top_material: Material
@export var white_top_material: Material
@export var red_top_material: Material

@export var top_base_material: Material
@export var speed_material: Material
@export_group("")

@export_group("Number Particles")
@export var number_to_particle_mesh: Array[Mesh]
@export var exclamation_particle_mesh: Mesh
@export var plus_mesh: Mesh
@export var minus_mesh: Mesh
@export var NumbersParticlePacked: PackedScene
@export_group("")

@export_group("Textures")
@export var turn_passed_texture: Texture2D
@export var turn_active_texture: Texture2D
@export var enemy_in_range_texture: Texture2D
@export var down_one: Texture2D
@export var down_two: Texture2D
@export var down_three: Texture2D
@export var up_one: Texture2D
@export var up_two: Texture2D
@export var up_three: Texture2D
@export_group("")

@export_group("Icons Manager")
@export var FofObjectIconPacked: PackedScene
@export_group("")

@export_group("Trait Combinations")
@export var trait_combinations: Array[TraitCombinationDatastore]
@export_group("")

@export_group("Shine Icons")
@export var default_shine: Texture2D
@export_group("")

@export_group("Default Models")
@export var AttackDefaultPacked: PackedScene
@export var HealthDefaultPacked: PackedScene
@export var SpeedDefaultPacked: PackedScene
@export_group("")

@export_group("Scripts")
@export var speed_model_script: GDScript
@export_group("")

var Card: CardGD

func setInfo(_Card: CardGD) -> void:
	Card = _Card
	Card.tool_updated.connect(onToolUpdated)
	position.y = Card.info.stat
	NumbersParticleManager.global_position.y = Card.position.y + (Card.info.top / 2.0)
	
	onResetStats()
	onUpdateTraits()
	onUpdateDelayedStats()
	onToolUpdated(Card.Tool)
	
	if Game.getLevel() != null:
		Game.getLevel().onRequestCameraPositionUpdate() # Updates for all field infos
	
func onResetStats() -> void:
	onResetDepthTest()
	onCreateFloatingNumbers()
	
func onResetDepthTest() -> void:
	setDepthTest(is_spectated)

func setDepthTest(state: bool) -> void:
	var mat: Material = null if !state else top_base_material
	ToolIcon.no_depth_test = state
	var meshes: Array = Helper.getNodeTypeRecursive(AttackFloatingStatSpot, MeshInstance3D) +\
		Helper.getNodeTypeRecursive(HealthFloatingStatSpot, MeshInstance3D)
	for mesh: MeshInstance3D in meshes:
		mesh.set_surface_override_material(0, mat)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	IconsManager.setDepthTest(state)
	
func setWhiteNumbersDepthTest(state: bool) -> void:
	var mat: Material = null if !state else white_top_material
	for mesh: MeshInstance3D in Helper.getNodeTypeRecursive(Numbers, MeshInstance3D):
		mesh.set_surface_override_material(0, mat)
	
func onCreateFloatingNumbers() -> void:
	onCreateSpecificStat(Game.Stats.ATTACK, Card.attack)
	onCreateSpecificStat(Game.Stats.HEALTH, Card.health)
	onCreateSpecificStat(Game.Stats.MAX_SPEED, Card.max_speed)
	onCreateSpecificStat(Game.Stats.SPEED, Card.speed)

func onCreateStat(spot: Node3D, value: int, above_green_value: int, below_red_value: int) -> void:
	for child in spot.get_children(): child.queue_free()
	var string_value: String = str(value)
	var numbers: Array = []
	
	for _char in string_value: numbers.append(int(_char))
	numbers = numbers.map(func(x: int): return number_to_model[x].instantiate())
	
	var mat: Material = white_with_outline_material if !is_spectated else white_top_material
	if value < below_red_value: mat = red_with_outline_material if !is_spectated else red_top_material
	elif value > above_green_value: mat = green_with_outline_material if !is_spectated else green_top_material
	
	for NumberModel in numbers:
		spot.add_child(NumberModel)
		var number_mesh: MeshInstance3D = Helper.getNodeTypeRecursive(NumberModel, MeshInstance3D)[0]
		number_mesh.set_surface_override_material(0, mat)
		number_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	spot.scale = getSpotScale(numbers.size())
	
	if numbers.size() == 2:
		numbers[0].position.x = -0.125
		numbers[1].position.x = 0.125
		
func getSpotScale(amount: int) -> Vector3:
	return Vector3.ONE if amount == 1 else Vector3(0.75, 0.75, 0.75)
		
var is_spectated: bool = false
func onSpectated(state: bool) -> void:
	is_spectated = state
	onResetStats()

func onCameraPositionUpdated(pos: Vector3) -> void:
	look_at(pos, Vector3(0, 1, 0), true)
	rotation.x = 0
	
func onUpdateStat(type: Game.Stats, value: int, difference: int, play_animation: bool = false, show_particles: bool = true) -> void:
	var spot: Node3D
	match type:
		Game.Stats.HEALTH, Game.Stats.MAX_HEALTH: spot = HealthSpot
		Game.Stats.ATTACK: spot = AttackSpot
	
	if play_animation:
		if spot != null:
			var tween := get_tree().create_tween()
			tween.tween_property(spot, "scale:y", 0.001, Game.STAT_UPDATE_TIME)
			
			await tween.finished
		
		onCreateSpecificStat(type, value)
		if show_particles: setNumbersParticle(type, difference)
		
		if spot != null:
			spot.scale.y = 0.001
			var reset_tween := get_tree().create_tween()
			reset_tween.tween_property(spot, "scale:y", getSpotScale(1 if value < 10 else 2).y, Game.STAT_UPDATE_TIME)
		return
	onCreateSpecificStat(type, value)
			
func onCreateSpecificStat(type: Game.Stats, value: int) -> void:
	var stat_datastore: StatsDatastore = Card.getStatsFromInfo()
	match type:
		Game.Stats.MAX_SPEED: onCreateMaxSpeedStat(value, stat_datastore.speed, Card.speed)
		Game.Stats.SPEED: onUpdateSpeedStat(value)
		Game.Stats.HEALTH: onCreateStat(HealthSpot, value, stat_datastore.health, Card.max_health)
		Game.Stats.ATTACK: onCreateStat(AttackSpot, value, stat_datastore.attack, Card.attack)
		
func setNumbersParticle(type: Game.Stats, value: int) -> void:
	var NumbersParticle: GPUParticles3D = NumbersParticlePacked.instantiate()
	NumbersParticleManager.add_child(NumbersParticle)
	var sign_mesh: Mesh = (plus_mesh if value > 0 else minus_mesh).duplicate()
	var number_mesh: Mesh = (number_to_particle_mesh[abs(value)] if abs(value) < 10 else exclamation_particle_mesh).duplicate()
	
	var mat: Material
	match type:
		Game.Stats.MAX_SPEED: mat = dark_green_with_outline_material
		Game.Stats.SPEED: mat = green_with_outline_material
		Game.Stats.ATTACK: mat = orange_with_outline_material
		Game.Stats.HEALTH: 
			if value > 0: mat = pink_with_outline_material
			else: mat = red_with_outline_material
		Game.Stats.MAX_HEALTH: mat = red_with_outline_material
	
	sign_mesh.surface_set_material(0, mat)
	number_mesh.surface_set_material(0, mat)
	NumbersParticle.draw_pass_1 = sign_mesh
	NumbersParticle.draw_pass_2 = number_mesh
	NumbersParticle.emitting = true
	
	await NumbersParticle.finished
	NumbersParticle.queue_free()

#region InfoSprite
func onUpdateTurnState(instant: bool = false) -> void:
	if Card.turn_state == Game.TurnStates.NULL: return
	onUpdateSpeedStat(Card.speed, instant)
#endregion

#region Traits
func onUpdateTraits() -> void:
	var field_traits_info: Array = Card.getFieldTraits().filter(func(x: TraitGD): return x.info.replace_model != null).map(func(y: TraitGD): return y.info)
	var stat_to_model: Dictionary = {
		Game.Stats.ATTACK: AttackDefaultPacked,
		Game.Stats.HEALTH: HealthDefaultPacked,
		Game.Stats.SPEED: SpeedDefaultPacked
	}
	
	for trait_combination in trait_combinations:
		if trait_combination.traits.all(func(x: TraitInfo): return x in field_traits_info):
			for trait_info in trait_combination.traits:
				field_traits_info.erase(trait_info)
			stat_to_model[trait_combination.replace_stat] = trait_combination.replace_model
	
	for field_trait_info in field_traits_info:
		stat_to_model[field_trait_info.replace_stat] = field_trait_info.replace_model
			
	for stat in stat_to_model:
		var replace_stat_spot: Node3D
		match stat:
			Game.Stats.ATTACK: replace_stat_spot = AttackFloatingStatSpot
			Game.Stats.HEALTH: replace_stat_spot = HealthFloatingStatSpot
			#Game.Stats.SPEED: replace_stat_spot = SpeedFloatingStatSpot
		
		if replace_stat_spot == null: continue # Added for speed
		for child in replace_stat_spot.get_children(): child.queue_free()
		replace_stat_spot.add_child(stat_to_model[stat].instantiate())
		
	onResetDepthTest()
#endregion

#region IconsManager
func onRemoveIcon(FofObject: FofGD) -> void:
	var icon_node: Sprite3D = onFindIconNode(FofObject)
	if icon_node != null: icon_node.queue_free()
	
func onAddIcon(FofObject: FofGD, _icon: Texture2D = FofObject.getIcon()) -> Node3D:
	var FofObjectIcon: Node3D = FofObjectIconPacked.instantiate()
	IconsManager.add_child(FofObjectIcon)
	FofObjectIcon.setInfo(FofObject)
	FofObjectIcon.setTexture(FofObject.getIcon())
	return FofObjectIcon
	
func onFindIconNode(FofObject: FofGD) -> Sprite3D:
	for child in IconsManager.get_children():
		if child.FofObject == FofObject: return child
	return null
#endregion

#region Delayed Stats
func onUpdateDelayedStats() -> void:
	onResetNullIcons()
	var stats: Dictionary = {Game.Stats.ATTACK: 0, Game.Stats.SPEED: 0, Game.Stats.HEALTH: 0, Game.Stats.MAX_SPEED: 0, Game.Stats.MAX_HEALTH: 0}
	for delayed: Variant in Card.delayed_stats.filter(func(x: Variant): return x.turns == 1):
		for i in range(delayed.getSize()):
			stats[delayed.getType(i)] += delayed.getValue(i)
	
	for stat in stats:
		if stats[stat] != 0: onAddDelayedStatNode(stat, stats[stat])
	
func onAddDelayedStatNode(type: Game.Stats, value: int) -> void:
	var FofObjectIcon: Node3D = FofObjectIconPacked.instantiate()
	IconsManager.add_child(FofObjectIcon)
	FofObjectIcon.setInfo(null)
	
	var texture: Texture2D
	match value:
		1: texture = up_one
		2, 3: texture = up_two
		
		-1: texture = down_one
		-2, -3: texture = down_two
		
		_:
			if value > 3: texture = up_three
			elif value < -3: texture = down_three
	
	var icon_color: Color
	match type:
		Game.Stats.ATTACK: icon_color = Color(1, 0.5, 0)
		Game.Stats.HEALTH: icon_color = Color(1, 0, 0)
		Game.Stats.SPEED: icon_color = Color(0, 1, 0)
		Game.Stats.MAX_HEALTH: icon_color = Color(1, 0, 1)
		Game.Stats.MAX_SPEED: icon_color = Color(0, 0.5, 0)
	
	FofObjectIcon.setTexture(texture)
	FofObjectIcon.setModulate(icon_color)

func onResetNullIcons() -> void:
	for child in IconsManager.get_children():
		if child.FofObject == null: child.queue_free()

func onToolUpdated(Tool: ToolGD) -> void:
	if Tool == null:
		ToolIcon.texture = null
	else:
		ToolIcon.texture = Tool.getIcon()
#endregion

const PASSED_MAX_GREY: float = 0.2
const REGULAR_MAX_GREY: float = 0.5
const BRIGHTNESS_MAX: float = 2.0

const SPEED_MODEL_TILT: float = 7.5
const SPEED_MODEL_GREY_TIME: float = 0.25
const SPEED_MODEL_DESTROY_TIME: float = 0.5
const SPEED_MODEL_CREATE_TIME: float = 0.5
const SPEED_MODEL_MOVE_SPEED: float = 0.25

var to_be_destroyed_models: Array = []
func onUpdateSpeedStat(speed: int, instant: bool = false) -> void:
	var max_speed: int = Card.max_speed
	var speed_models: Array = SpeedFloatingStatSpot.get_children()
	for i: int in range(max_speed):
		if i >= speed_models.size(): continue
		if speed_models[i] in to_be_destroyed_models: continue
		
		var SpeedModel: Node3D = speed_models[i]
		setSpeedModelMaterial(SpeedModel, i, instant)

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
