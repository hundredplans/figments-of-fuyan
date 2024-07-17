class_name UnitGD
extends Node3D

signal update_ai_stat
var is_dead: bool = false
var id: int = 0
var unit_fx: Array = []
var is_spectated: bool = false
var visible_state: bool = false

var hero_card: HeroCardGD
var base_card: BaseCardGD
var ai: Dictionary
var was_placed: bool = false

var attack: int

var max_speed: int
var speed: int

var max_health: int
var health: int

var rarity: int
var team: int = 0
var height: Dictionary
var Tile: TileGD

var heal_multiplier: int = 1
var extra_heal: int = 0
var extra_damage: int = 0
var attack_range: int = 1
var attack_amount: int = 1

var turns_alive: int = 0
var turn_status: int = TURN_UNUSED
var finished_awakening: bool = false
var traits: Array = []
var abilities: Array = []
var base_text: String

var ai_info: AIInfoGD

enum {
	TURN_ACTIVE, # Unit is actively moving / selected
	TURN_INACTIVE, # Phase where unit can't be selected
	TURN_USED, # It's the unit's phase and he's already moved
	TURN_UNUSED, # It's the unit's phase and he hasn't moved yet
}

@onready var UnitVFX: Node3D = $UnitVFX
@onready var Model: Node3D

var Boons: BoonsGD
var VFX: VFXGD
var Tiles: TilesGD
var Combat: CombatGD
var AudioDict: AudioDictGD
var Vision: VisionGD
var SpectateCamera: SpectateCameraGD
var Units: UnitsGD
var GameEffects: GameEffectsGD
var LevelUI: LevelUIGD
var StatusManager: StatusManagerGD
var ActionManager: ActionManagerGD
var PlayerManager: PlayerManagerGD
var LevelMap: LevelMapGD
var TriggerManager: TriggerManagerGD

var Tool: ToolGD

func _ready() -> void: Helper.onCreateChildReferences(self)


func onEquipTool(_Tool: ToolGD) -> void:
	if Tool != null:
		TriggerManager.onUnitTrigger(self, TriggerGD.UNEQUIP_TOOL, UnequipToolTriggerInfoGD.new(_Tool, Tool))
		Tool.onRemoveSelf()
	
	Tool = _Tool
	
	if Tool != null:
		Tool.onUnitAwakened(self)
		TriggerManager.onUnitTrigger(self, TriggerGD.EQUIP_TOOL, EquipToolTriggerInfoGD.new(Tool))

func onUnitAwakened(_id: int, _team: int, rot: int, tile: TileGD) -> void:
	id = _id
	team = _team
	
	var card: BaseCardGD = Helper.getCard(id).duplicate()
	base_card = card
	base_text = base_card.text
	
	ai = {"aic": base_card.aic, "aii": base_card.aii, "aiw": base_card.aiw, "ait": base_card.ait, "aia": base_card.aia}
	attack = base_card.attack
	health = base_card.health
	rarity = base_card.rarity
	
	speed = base_card.speed
	max_speed = base_card.speed
	
	max_health = base_card.health
	height = {
		"top": base_card.top,
		"eye": base_card.eye,
		"stat": base_card.stat
	}
	
	var card_model_path: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/model.tscn"
	
	Model = load(card_model_path).instantiate() # Takes about 2.2seconds, not the ready function?
	Model.Unit = self
	Model.rot = rot
	add_child(Model)
	
	VisionRaycast.position.y = height.eye
	
	position = tile.position
	position.y += 0.3 if !Tiles.is_ramp_tile(tile) else 0.9
	ai_info = AIInfoGD.new()
	if team == 1:
		Model.setVisible(false)
		if LevelUI.Console.move_state_state:
			VFX.onUpdateMoveState(self)
			
		if LevelUI.Console.ai_stats_state:
			VFX.onUpdateAiStats(self)
			
	ai_info.danger = base_card.default_danger
	ai_info.safety = base_card.default_safety
	
	AudioDict = load("res://assets/base_game/cards/cards/" + base_card.folder_name + "/audio.tres")
	onCreateAbilities()
	onCreateTraits()
	
func onCreateTraits() -> void:
	var DIR_PATH: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/traits/"
	if DirAccess.dir_exists_absolute(DIR_PATH):
		for trait_name in DirAccess.get_files_at(DIR_PATH):
			var Trait: TraitGD = load(DIR_PATH + trait_name).duplicate()
			traits.append(Trait)

func onCreateAbilities() -> void:
	var DIR_PATH: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/abilities/"
	if DirAccess.dir_exists_absolute(DIR_PATH):
		for ability_name in Array(DirAccess.get_files_at(DIR_PATH)).filter(func(x: String): return x.ends_with(".tres")):
			
			var ability: AbilityGD = load(DIR_PATH + ability_name).duplicate()
			ability.charges = ability.max_charges
			abilities.append(ability)
			
			if ability is TargetAbilityGD or ability is OngoingAbilityGD: ability.setInfo(self)
			
func onAddUnitFX(info_fx: InfoFXGD) -> void:
	unit_fx.append(info_fx)
		
func onRemoveUnitFX(info_fx: InfoFXGD) -> void:
	unit_fx.erase(info_fx)
		
var vision_info_array: Array = []

func onCanAttack() -> bool:
	return attack_amount > 0 and !Combat.isStaggered(self)

func onChangeTile(_Tile: TileGD) -> void:
	if Tile != null: Tile.Unit = null
	Tile = _Tile
	Tile.Unit = self

func occupy_tile(_Tile: TileGD) -> void:
	onChangeTile(_Tile)
	if vision_info_array.is_empty(): Vision.onRecalculateVision(self)
	else: Vision.onRecalculateVisionPrecalculated(self, vision_info_array.pop_front())
	
func changeStats(stat_info: StatInfoGD) -> int:
	var diff: int = stat_info.value
	match stat_info.stat_type:
		StatsGD.ATTACK:
			if stat_info.absolute: diff = stat_info.value - attack; attack = clamp(stat_info.value, 0, 99)
			else: attack = clamp(attack + stat_info.value, 0, 99)
		StatsGD.HEALTH:
			if stat_info.absolute: diff = stat_info.value - health; health = clamp(stat_info.value, 0, max_health)
			else: health = clamp(health + stat_info.value, 0, max_health)
		StatsGD.MAX_HEALTH:
			if stat_info.absolute: diff = stat_info.value - max_health; max_health = clamp(stat_info.value, 0, 99)
			else: max_health = clamp(max_health + stat_info.value, 0, 99)
		StatsGD.BOTH_HEALTH:
			if stat_info.absolute: diff = stat_info.value - health; max_health = clamp(stat_info.value, 0, 99); health = max_health
			else: max_health = clamp(max_health + stat_info.value, 0, 99); health = clamp(health + stat_info.value, 0, max_health)
		StatsGD.CURRENT_SPEED:
			if stat_info.absolute: diff = stat_info.value - speed; speed = clamp(stat_info.value, 0, max_speed)
			else: speed = clamp(speed + stat_info.value, 0, max_speed)
		StatsGD.MAX_SPEED:
			if stat_info.absolute: diff = stat_info.value - max_speed; max_speed = clamp(stat_info.value, 0, 9)
			else: max_speed = clamp(max_speed + stat_info.value, 0, 9)
		StatsGD.BOTH_SPEED:
			if stat_info.absolute: diff = stat_info.value - speed; max_speed = clamp(stat_info.value, 0, 9); speed = max_speed
			else: max_speed = clamp(max_speed + stat_info.value, 1, 9); speed = clamp(speed + stat_info.value, 1, max_speed)
	return diff
	
var Killer: UnitGD
func stats(stat_type: String, val: int, AppliedBy := AppliedByGD.new("GameEvent"), absolute: bool = false) -> void:
	pass
	
var is_arrive_rotate: bool = false
func on_arrive(in_vision: bool) -> void:
	if in_vision:
		var RotateTween := create_tween()
		RotateTween.tween_property(self, "rotation:y", 2 * TAU, Units.ARRIVE_EFFECT_DELAY_DURATION * 1.2)\
		.as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		AudioMaster.play_sfx(AudioDict.ARRIVE)

func on_death() -> void:
	if Tool != null: Tool.onRemoveSelf()
	Tile.Unit = null
	Tiles.on_remove_tile_material(Tile, "EmptyTile")
	reparent(Units.Postmortem)
	visible = false
	is_dead = true
	global_position = Vector3(1024, 1024, 1024)
	await get_tree().process_frame
	
func onSpectatedPlayerPhase(state: bool) -> void:
	if LevelMap.game_phase == "PlayerPhase":
		StatusManager.onUnitSpectated(self, state)
		Model.onSetOutlineProperties(state)
		LevelUI.on_update_vision()
		if turn_status == UnitGD.TURN_USED: Units.setPastPath(self, state)
		is_spectated = state
		setCollisionLayerSpectated()
		PlayerManager.onUnitMode(self, state)
	
func setCollisionLayerSpectated() -> void:
	Model.static_body.collision_layer = 4 if (is_spectated or !visible_state) else 36
	
func on_enemy_in_range(state: bool) -> void:
	StatusManager.onEnemyInRange(self, state)
	Model.onSetOutlineProperties(state)
	Tiles.setTileOutline(Tile, "EnemyInRange", !state)

var visible_tiles: Array
@onready var VisionRaycast: RayCast3D = $VisionRaycast
const VISION_RANGE: int = 5

var past_path_set: bool = false
var past_path_info: Dictionary = {} # TileGD: [rot, [nums]]
var past_path_counter: int = 0

func onCalculateVisionInfo() -> VisInfoGD:
	var _visible_tiles: Array = []
	if !is_dead:
		var tiles: Array = Tiles.onTilesInVisionRange(Tile, VISION_RANGE)
		var current_units: Array = Units.all_units(self).filter(func(x: UnitGD): return x.Tile in tiles)
		var collision_infos: Array = []
		
		for _Tile in tiles: collision_infos.append([_Tile, _Tile.collision_points])
		for Unit in current_units: collision_infos.append([Unit, Unit.Model.onGetAdjustedPoints()])

		for info in collision_infos:
			var potential_collision: Node3D = info[0]
			for point in info[1]:
				VisionRaycast.target_position = (point - VisionRaycast.global_position) * 1.05
				VisionRaycast.force_raycast_update()
				if VisionRaycast.is_colliding():
					var Collision: Node3D = VisionRaycast.get_collider().get_node("../../../..")
					var _Tile: TileGD = Collision if Collision is TileGD else Collision.Tile
					onAppendTileToVisibleTiles(_visible_tiles, _Tile)
					if Collision == potential_collision: break
		onAddNonCommutativeUnits(_visible_tiles)
		onUnitsHeightAdjacentTiles(_visible_tiles)
	
	return VisInfoGD.new(_visible_tiles, onCalculateUnitVision(_visible_tiles))
	
func onCalculateEnemyUnitCommutative(Unit: UnitGD) -> bool:
	if Unit.Tile in visible_tiles: return true
	for point in Unit.Model.onGetAdjustedPoints() + Unit.Tile.collision_points:
		VisionRaycast.target_position = (point - VisionRaycast.global_position) * 1.05
		VisionRaycast.force_raycast_update()
		
		if VisionRaycast.is_colliding():
			var Collision: Node3D = VisionRaycast.get_collider().get_node("../../../..")
			if Collision == Unit: return true
	return false

func onAddNonCommutativeUnits(_visible_tiles: Array) -> void:
	for Unit in Units.all_units(self):
		if Tiles.tile_distance(Unit.Tile, Tile) <= Vision.VISION_RANGE and Unit.Tile not in _visible_tiles and Unit.onCalculateEnemyUnitCommutative(self):
			_visible_tiles.append(Unit.Tile)

func onCalculateUnitVision(_visible_tiles: Array = []) -> Dictionary:
	var intent: Dictionary = {}
	for _Unit in Units.all_units(self):
		var isvisible: bool = _Unit.Tile in _visible_tiles
		var wasvisible: bool = _Unit.Tile in visible_tiles
		if (isvisible and !wasvisible): intent[_Unit] = VisInfoGD.ENTER
		elif (wasvisible and !isvisible): intent[_Unit] = VisInfoGD.EXIT
		elif (!isvisible and !wasvisible): intent[_Unit] = VisInfoGD.INVISIBLE
		else: intent[_Unit] = VisInfoGD.REGULAR
	return intent

func onAppendTileToVisibleTiles(_visible_tiles: Array, _Tile: TileGD) -> void:
	if _Tile not in _visible_tiles: _visible_tiles.append(_Tile)
	for __Tile in _Tile.top_of_cliff_wall: if __Tile not in _visible_tiles: _visible_tiles.append(__Tile)
	for type in ["obj", "wdeco", "tdeco"]:
		for __Tile in _Tile[type].multi_tile:
			if __Tile not in _visible_tiles: _visible_tiles.append(__Tile)
	
func onUnitsHeightAdjacentTiles(_visible_tiles: Array) -> void:
	for direction in Tiles.cube_directions:
		for w in range(Tile.w, -1, -1):
			var pos: Vector3 = Tile.tpos + direction
			var _Tile: TileGD = Tiles.position_to_tile(Vector4(pos.x, pos.y, pos.z, w))
			if _Tile != null and _Tile.tile.id > 0:
				onAppendTileToVisibleTiles(_visible_tiles, _Tile)
				break

func getVisibleUnits() -> Array:
	var visible_units: Array = visible_tiles.map(func(x: TileGD): return Units.unit_by_tile(x))
	return visible_units.filter(func(x: Variant): return x != null and !x.is_dead and x != self and x.health > 0)

func getVisibleEnemies() -> Array:
	return getVisibleUnits().filter(Units.on_match_team_relation.bind(team, "Enemy"))

func getVisibleAllies() -> Array:
	return getVisibleUnits().filter(Units.on_match_team_relation.bind(team, "Ally"))

func onResetUnit(default_body_pos: Vector3, default_ray_pos: Vector3, default_rot: int, default_tile: TileGD) -> void:
	Model.static_body.position = default_body_pos
	VisionRaycast.position = default_ray_pos
	Model.rot = default_rot
	onChangeTile(default_tile)
	Model.onSetCollisionRotation()

func isHealable() -> bool:
	return health < max_health

func getAttackAnimation() -> String:
	if GameEffects.onGameFXExists(self, GameFXGD.ABILITY_ACTIVE):
		return "AttackAbility"
	return "Attack"
	
func getVisibleTiles() -> Array: # Removes tile unit is on
	return visible_tiles.filter(func(x: TileGD): return x != Tile)

func setExtraDamage(x: int = 0) -> void:
	extra_damage = x

func setHealMultiplier(x: int = 1) -> void:
	heal_multiplier = x

func onAddToPastPath(_Tile: TileGD) -> void:
	past_path_counter += 1
	if !past_path_info.has(Tile): past_path_info[Tile] = [[], []]
	past_path_info[Tile][0].append(Tiles.neighbour_rotation(_Tile, Tile))
	past_path_info[Tile][1].append(past_path_counter)

func setVisibleState(state: bool) -> void:
	visible_state = state
	setCollisionLayerSpectated()

func onChangeAIStat(ai_stat: String, val: int) -> void:
	ai[ai_stat] = clamp(ai[ai_stat] + val, 1, 7)
	update_ai_stat.emit(self)
	
func onResetAIStat(ai_stat: String) -> void:
	ai[ai_stat] = base_card[ai_stat]
	update_ai_stat.emit(self)
