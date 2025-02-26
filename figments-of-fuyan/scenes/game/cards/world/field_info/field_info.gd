extends Node3D

#region Onreadies
@onready var FloatingStats: Node3D = %FloatingStats

@onready var AttackFloatingStatSpot: Node3D = %AttackFloatingStatSpot
@onready var HealthFloatingStatSpot: Node3D = %HealthFloatingStatSpot
@onready var SpeedFloatingStatSpot: Node3D = %SpeedFloatingStatSpot

@onready var AttackSpot: Node3D = %AttackSpot
@onready var HealthSpot: Node3D = %HealthSpot
@onready var SpeedSpot: Node3D = %SpeedSpot

@onready var InfoSprite: Sprite3D = %InfoSprite
@onready var Numbers: Node3D = %Numbers
@onready var IconsManager: Node3D = %IconsManager

@onready var ToolIcon: Sprite3D = %ToolIcon
@onready var ToolShine: Sprite3D = %ToolShine

@onready var NumbersParticleManager: Node3D = %NumbersParticleManager
#endregion

@export var number_to_model: Array[PackedScene]
@export_group("Materials")
@export var green_material: Material
@export var white_material: Material
@export var red_material: Material
@export var pink_material: Material
@export var orange_material: Material

@export var green_top_material: Material
@export var white_top_material: Material
@export var red_top_material: Material

@export var top_base_material: Material
@export var black_outline_material: Material
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
@export var ascended_shine: Texture2D
@export_group("")

@export_group("Default Models")
@export var AttackDefaultPacked: PackedScene
@export var HealthDefaultPacked: PackedScene
@export var SpeedDefaultPacked: PackedScene
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
	
	Game.getLevel().onRequestCameraPositionUpdate() # Updates for all field infos
	
func onResetStats() -> void:
	onResetDepthTest()
	onCreateFloatingNumbers()
	
func onResetDepthTest() -> void:
	var mat: Material = null if !is_spectated else top_base_material
	InfoSprite.no_depth_test = is_spectated
	ToolIcon.no_depth_test = is_spectated
	ToolShine.no_depth_test = is_spectated
	for mesh: MeshInstance3D in Helper.getNodeTypeRecursive(FloatingStats, MeshInstance3D):
		mesh.set_surface_override_material(0, mat)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	IconsManager.setDepthTest(is_spectated)
	
func onCreateFloatingNumbers() -> void:
	onCreateSpecificStat(Game.Stats.ATTACK, Card.attack)
	onCreateSpecificStat(Game.Stats.HEALTH, Card.health)
	onCreateSpecificStat(Game.Stats.SPEED, Card.speed)

func onCreateStat(spot: Node3D, value: int, above_green_value: int, below_red_value: int) -> void:
	for child in spot.get_children(): child.queue_free()
	var string_value: String = str(value)
	var numbers: Array = []
	
	for _char in string_value: numbers.append(int(_char))
	numbers = numbers.map(func(x: int): return number_to_model[x].instantiate())
	
	var mat: Material = white_material if !is_spectated else white_top_material
	#var mat: Material = black_outline_material
	if value < below_red_value: mat = red_material if !is_spectated else red_top_material
	elif value > above_green_value: mat = green_material if !is_spectated else green_top_material
	
	for NumberModel in numbers:
		spot.add_child(NumberModel)
		var number_mesh: MeshInstance3D = Helper.getNodeTypeRecursive(NumberModel, MeshInstance3D)[0]
		number_mesh.set_surface_override_material(0, mat)
		number_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		#if number_mesh.get_surface_override_material_count() > 1:
			#number_mesh.set_surface_override_material(1, black_outline_material)
	
	spot.scale = Vector3.ONE if numbers.size() == 1 else Vector3(0.75, 0.75, 0.75)
	if numbers.size() == 2:
		numbers[0].position.x = -0.125
		numbers[1].position.x = 0.125
		
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
		Game.Stats.SPEED: spot = SpeedSpot
		Game.Stats.HEALTH, Game.Stats.MAX_HEALTH: spot = HealthSpot
		Game.Stats.ATTACK: spot = AttackSpot
	
	if spot != null:
		if play_animation:
			var tween := get_tree().create_tween()
			tween.tween_property(spot, "scale:y", 0.001, Game.STAT_UPDATE_TIME)
			
			await tween.finished
			
			var reset_tween := get_tree().create_tween()
			
			onCreateSpecificStat(type, value)
			if show_particles: setNumbersParticle(type, difference)
			
			var old_scale: float = spot.scale.y
			spot.scale.y = 0.001
			reset_tween.tween_property(spot, "scale:y", old_scale, Game.STAT_UPDATE_TIME)
			return
		onCreateSpecificStat(type, value)
			
func onCreateSpecificStat(type: Game.Stats, value: int) -> void:
	match type:
		Game.Stats.SPEED: onCreateStat(SpeedSpot, value, Card.info.speed, Card.speed)
		Game.Stats.HEALTH: onCreateStat(HealthSpot, value, Card.info.health, Card.max_health)
		Game.Stats.ATTACK: onCreateStat(AttackSpot, value, Card.info.attack, Card.info.attack)

func setNumbersParticle(type: Game.Stats, value: int) -> void:
	var NumbersParticle: GPUParticles3D = NumbersParticlePacked.instantiate()
	NumbersParticleManager.add_child(NumbersParticle)
	var sign_mesh: Mesh = (plus_mesh if value > 0 else minus_mesh).duplicate()
	var number_mesh: Mesh = (number_to_particle_mesh[abs(value)] if abs(value) < 10 else exclamation_particle_mesh).duplicate()
	
	var mat: Material
	match type:
		Game.Stats.SPEED: mat = green_material
		Game.Stats.ATTACK: mat = orange_material
		Game.Stats.HEALTH: 
			if value > 0: mat = pink_material
			else: mat = red_material
		Game.Stats.MAX_HEALTH: mat = red_material
	
	sign_mesh.surface_set_material(0, mat)
	number_mesh.surface_set_material(0, mat)
	NumbersParticle.draw_pass_1 = sign_mesh
	NumbersParticle.draw_pass_2 = number_mesh
	NumbersParticle.emitting = true
	
	await NumbersParticle.finished
	NumbersParticle.queue_free()

#region InfoSprite
func setInfoSpriteTurnState() -> void:
	match Card.turn_state:
		Game.TurnStates.PASSED: InfoSprite.texture = turn_passed_texture
		Game.TurnStates.ACTIVE: InfoSprite.texture = turn_active_texture
		_: InfoSprite.texture = null
		
func setInfoSpriteEnemyInMovementRange(state: bool) -> void:
	if state: InfoSprite.texture = enemy_in_range_texture
	else: setInfoSpriteTurnState()
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
			Game.Stats.SPEED: replace_stat_spot = SpeedFloatingStatSpot
		
		for child in replace_stat_spot.get_children(): child.queue_free()
		replace_stat_spot.add_child(stat_to_model[stat].instantiate())
		
	onResetDepthTest()
#endregion

#region IconsManager
func onRemoveIcon(FofObject: FofGD) -> void:
	onFindIconNode(FofObject).queue_free()
	
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
	for stat_info in Card.delayed_stats.filter(func(x: StatInfo): return x.turns == 1):
		for i in range(stat_info.types.size()):
			stats[stat_info.types[i]] += stat_info.values[i]
	
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
		ToolShine.visible = false
		ToolShine.texture = null
	else:
		ToolIcon.texture = Tool.getIcon()
		ToolShine.visible = Tool.getAscended()
		ToolShine.texture = null if !Tool.getAscended() else ascended_shine
#endregion
