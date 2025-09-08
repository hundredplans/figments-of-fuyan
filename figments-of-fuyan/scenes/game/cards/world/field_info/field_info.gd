extends BaseFieldInfo

#region Onreadies
@onready var FloatingStats: Node3D = %FloatingStats

@onready var AttackFloatingStatSpot: Node3D = %AttackFloatingStatSpot
@onready var HealthFloatingStatSpot: Node3D = %HealthFloatingStatSpot

@onready var AttackSpot: Node3D = %AttackSpot
@onready var HealthSpot: Node3D = %HealthSpot

@onready var Numbers: Node3D = %Numbers
@onready var IconsManager: Node3D = %IconsManager

@onready var ToolIconDisplay: MeshInstance3D = %ToolIconDisplay
@onready var ToolIcon: Control = %ToolIcon

@onready var NumbersParticleManager: Node3D = %NumbersParticleManager
#endregion

@export var number_to_model: Array[PackedScene]
@export_group("Materials")
@export var tier_one_material: Material
@export var tier_two_material: Material
@export var tier_three_material: Material
@export var tier_four_material: Material

@export var tier_one_material_no_dt: Material
@export var tier_two_material_no_dt: Material
@export var tier_three_material_no_dt: Material
@export var tier_four_material_no_dt: Material

@export var dark_green_with_outline_material: Material
@export var green_with_outline_material: Material
@export var red_with_outline_material: Material
@export var white_with_outline_material: Material
@export var pink_with_outline_material: Material
@export var orange_with_outline_material: Material
@export var tool_icon_material: Material
@export var tool_icon_material_no_dt: Material

@export var green_top_material: Material
@export var white_top_material: Material
@export var red_top_material: Material

@export var top_base_material: Material
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
@export_group("")

func setInfo(_Card: CardGD) -> void:
	super(_Card)
	Card.tool_updated.connect(onToolUpdated)
	Card.update_tier.connect(onUpdateTier)
	position.y = Card.info.stat
	NumbersParticleManager.global_position.y = Card.position.y + (Card.info.top / 2.0)
	
	onUpdateTraits()
	onUpdateDelayedStats()
	onUpdateTier(Card.getTier())
	
	ToolIcon.setSizeScale(4)
	onToolUpdated(Card.Tool)
	
	if Game.getLevel() != null:
		Game.getLevel().onRequestCameraPositionUpdate() # Updates for all field infos

func setDepthTest(state: bool, override: bool = false) -> void:
	if state == depth_test_state or override: return
	super(state, override)
	
	IconsManager.setDepthTest(state)
	var _tool_icon_material: Material = tool_icon_material if !depth_test_state else tool_icon_material_no_dt
	ToolIconDisplay.set_surface_override_material(0, _tool_icon_material)
	onUpdateTier(Card.getTier())
	
func setWhiteNumbersDepthTest(state: bool) -> void:
	var mat: Material = null if !state else white_top_material
	for mesh: MeshInstance3D in Helper.getNodeTypeRecursive(Numbers, MeshInstance3D):
		mesh.set_surface_override_material(0, mat)
	
func onCreateFloatingNumbers() -> void:
	super()
	onCreateSpecificStat(Game.Stats.ATTACK, Card.attack)
	onCreateSpecificStat(Game.Stats.HEALTH, Card.health)

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

func onCameraPositionUpdated(pos: Vector3) -> void:
	look_at(pos, Vector3(0, 1, 0), true)
	rotation.x = 0
	
func onUpdateStat(type: Game.Stats, value: int, difference: int, play_animation: bool = false, show_particles: bool = true) -> void:
	super(type, value, difference, play_animation, show_particles)
	if type in [Game.Stats.SPEED, Game.Stats.MAX_SPEED]:
		if show_particles: setNumbersParticle(type, difference)
		return
	
	var spot: Node3D
	var FloatingStatModel: Node3D
	match type:
		Game.Stats.HEALTH, Game.Stats.MAX_HEALTH:
			spot = HealthSpot
			FloatingStatModel = HealthFloatingStatSpot
		Game.Stats.ATTACK:
			spot = AttackSpot
			FloatingStatModel = AttackFloatingStatSpot
	
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
		
		if FloatingStatModel != null:
			var tween := get_tree().create_tween()
			tween.tween_property(FloatingStatModel, "rotation:y", 2 * PI, FLOATING_STAT_SPIN_SPEED)\
				.as_relative().set_trans(Tween.TRANS_SINE)
		return
	onCreateSpecificStat(type, difference)
			
func onCreateSpecificStat(type: Game.Stats, value: int) -> void:
	super(type, value)
	var stat_datastore: StatsDatastore = Card.getStatsFromInfo()
	match type:
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
	onUpdateTier(Card.getTier())
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
	ToolIcon.setInfo(Tool)
	ToolIcon.onShowTierLabel()
#endregion

const FLOATING_STAT_SPIN_SPEED: float = 0.5
func onUpdateTier(tier: int) -> void:
	var mat: Material
	if !depth_test_state:
		match tier:
			1: mat = tier_one_material
			2: mat = tier_two_material
			3: mat = tier_three_material
			_: mat = tier_four_material
	else:
		match tier:
			1: mat = tier_one_material_no_dt
			2: mat = tier_two_material_no_dt
			3: mat = tier_three_material_no_dt
			_: mat = tier_four_material_no_dt
		
	var meshes: Array = Helper.getNodeTypeRecursive(AttackFloatingStatSpot, MeshInstance3D) +\
		Helper.getNodeTypeRecursive(HealthFloatingStatSpot, MeshInstance3D)
	for mesh: MeshInstance3D in meshes:
		mesh.set_surface_override_material(0, mat)
