extends Node3D

#region Onreadies
@onready var FloatingStats: Node3D = %FloatingStats

@onready var AttackFloatingStatSpot: Node3D = %AttackFloatingStatSpot
@onready var HealthFloatingStatSpot: Node3D = %HealthFloatingStatSpot
@onready var SpeedFloatingStatSpot: Node3D = %SpeedFloatingStatSpot

@onready var AttackSpot: Node3D = %AttackSpot
@onready var HealthSpot: Node3D = %HealthSpot
@onready var SpeedSpot: Node3D = %SpeedSpot

@onready var NumbersParticle: GPUParticles3D = %NumbersParticle

@onready var InfoSprite: Sprite3D = %InfoSprite
@onready var Numbers: Node3D = %Numbers
@onready var IconsManager: Node3D = %IconsManager
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
@export_group("")

@export_group("Number Particles")
@export var number_to_particle_mesh: Array[Mesh]
@export var exclamation_particle_mesh: Mesh
@export var plus_mesh: Mesh
@export var minus_mesh: Mesh
@export_group("")

@export_group("Textures")
@export var turn_passed_texture: Texture2D
@export var turn_active_texture: Texture2D
@export var enemy_in_range_texture: Texture2D
@export_group("")

@export_group("Icons Manager")
@export var FofObjectIconPacked: PackedScene
@export_group("")

var Card: CardGD

func setInfo(_Card: CardGD) -> void:
	Card = _Card
	position.y = Card.info.stat
	NumbersParticle.global_position.y = Card.info.top / 2.0
	
	onResetStats()
	onUpdateTraits()
	
func onResetStats() -> void:
	var mat: Material = null if !is_spectated else top_base_material
	InfoSprite.no_depth_test = is_spectated
	for mesh in Helper.getNodeTypeRecursive(FloatingStats, MeshInstance3D):
		mesh.set_surface_override_material(0, mat)
	
	IconsManager.setDepthTest(is_spectated)
	
	onCreateFloatingNumbers()
	
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
	if value < below_red_value: mat = red_material if !is_spectated else white_top_material
	elif value > above_green_value: mat = green_material if !is_spectated else green_top_material
	
	for NumberModel in numbers:
		spot.add_child(NumberModel)
		Helper.getNodeTypeRecursive(NumberModel, MeshInstance3D)[0].set_surface_override_material(0, mat)
	
	spot.scale = Vector3.ONE if numbers.size() == 1 else Vector3(0.75, 0.75, 0.75)
	if numbers.size() == 2:
		numbers[0].position.x = -0.125
		numbers[1].postiion.x = 0.125
		
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
		Game.Stats.HEALTH: spot = HealthSpot
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
	var sign_mesh: Mesh = (plus_mesh if value > 0 else minus_mesh).duplicate()
	var number_mesh: Mesh = (number_to_particle_mesh[value] if abs(value) < 10 else exclamation_particle_mesh).duplicate()
	
	var mat: Material
	match type:
		Game.Stats.SPEED: mat = green_material
		Game.Stats.ATTACK: mat = orange_material
		Game.Stats.HEALTH:
			if value > 0: mat = pink_material
			else: mat = red_material
	
	sign_mesh.surface_set_material(0, mat)
	number_mesh.surface_set_material(0, mat)
	NumbersParticle.draw_pass_1 = sign_mesh
	NumbersParticle.draw_pass_2 = number_mesh
	NumbersParticle.emitting = true

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
	for field_trait in Card.field_traits.filter(func(x: TraitGD): return x.info.replace_model != null):
		var replace_stat_spot: Node3D
		match field_trait.info.replace_stat:
			Game.Stats.ATTACK: replace_stat_spot = AttackFloatingStatSpot
			Game.Stats.HEALTH: replace_stat_spot = HealthFloatingStatSpot
			Game.Stats.SPEED: replace_stat_spot = SpeedFloatingStatSpot
			
		for child in replace_stat_spot.get_children(): child.queue_free()
		replace_stat_spot.add_child(field_trait.info.replace_model.instantiate())
#endregion

#region IconsManager
func onRemoveIcon(fof_object: FofGD) -> void:
	onFindIconNode(fof_object).queue_free()
	
func onAddIcon(FofObject: FofGD) -> void:
	var FofObjectIcon: Sprite3D = FofObjectIconPacked.instantiate()
	IconsManager.add_child(FofObjectIcon)
	FofObjectIcon.FofObject = FofObject
	FofObjectIcon.texture = FofObject.getIcon()
	
func onFindIconNode(FofObject: FofGD) -> Sprite3D:
	for child in IconsManager.get_children():
		if child.FofObject == FofObject: return child
	return null
#endregion
