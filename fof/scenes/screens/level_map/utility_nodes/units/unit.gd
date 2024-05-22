class_name UnitGD
extends Node3D

signal tile_occupied

var is_dead: bool = false
var id: int = 0
var tool_id: int = 0
var effects: Array = []
var unit_fx: Array = []

var hero_card: HeroCardGD
var base_card: BaseCardGD
var ai: Dictionary

var attack: int

var max_speed: int
var speed: int

var max_health: int
var health: int

var rarity: int
var team: int
var height: Dictionary
var Tile: TileGD

var heal_multiplier: int = 1
var extra_heal: int = 0
var extra_damage: int = 0
var attack_range: int = 1
var attack_amount: int = 1

var AudioDict: AudioDictGD
var Vision: VisionGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Tiles: TilesGD
var TeamControl: Node
var GameEffects: GameEffectsGD

var turns_alive: int = 0
var turn_status: String = "TurnUnused"
var finished_awakening: bool = false
var abilities: Array = []
var base_text: String

@onready var UnitVFX: Node3D = $UnitVFX
@onready var Model: Node3D
func on_create_unit(_id: int, _tool_id: int, _effects: Array, _team: int, rot: int, tile: TileGD) -> void:
	id = _id
	tool_id = _tool_id
	effects = _effects
	team = _team
	
	var card: BaseCardGD = Helper.getCard(id).duplicate()
	base_card = card
	base_text = base_card.text
	
	ai = {"aic": base_card.aic, "aii": base_card.aii, "aiw": base_card.aiw, "ait": base_card.ait, "aia": base_card.aia}
	attack = base_card.attack
	health = base_card.health
	
	speed = base_card.speed
	max_speed = base_card.speed
	
	max_health = base_card.health
	rarity = base_card.rarity
	height = {
		"top": base_card.top,
		"eye": base_card.eye,
		"weapon_offset": base_card.weapon_offset,
		"weapon": base_card.weapon,
		"stat": base_card.stat
	}
	
	var card_model_path: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/model.tscn"
	
	Model = load(card_model_path).instantiate() # Takes about 2.2seconds, not the ready function?
	Model.Unit = self
	Model.rot = rot
	add_child(Model)
	
	VisionRaycast.position.y = height.eye
	
	position = tile.position
	position.y += 0.3
	occupy_tile(tile)
	AudioDict = load("res://assets/base_game/cards/cards/" + base_card.folder_name + "/audio.tres")
	onCreateAbilities()

func onCreateAbilities() -> void:
	var DIR_PATH: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/abilities/"
	if DirAccess.dir_exists_absolute(DIR_PATH):
		for ability_name in Array(DirAccess.get_files_at(DIR_PATH)).filter(func(x: String): return x.ends_with(".tres")):
			var ability: AbilityGD = load(DIR_PATH + ability_name).duplicate()
			ability.VFX = Units.VFX
			ability.Units = Units
			ability.Tiles = Tiles
			ability.Vision = Vision
			ability.Combat = Units.Combat
			ability.GameEffects = Units.GameEffects
			ability.charges = ability.max_charges
			abilities.append(ability)
			
			if ability is ArmorGD:
				onAddUnitFX("Armor", ability.armor)
			
func onAddUnitFX(type: String, charges: int = -1) -> void:
	var info_fx: InfoFXGD = load(Units.LevelUI.UnitStatusOverlord.all_info_fx[type])
	info_fx.charges = charges
	unit_fx.append(info_fx)
		
func occupy_tile(_Tile: TileGD) -> void:
	var is_first: bool = Tile == null
	var OGTile: TileGD = Tile
	Tile = _Tile
	
	await get_tree().create_timer(0.001).timeout
	Vision.onExitTile(self, OGTile, _Tile)
	
	Vision.on_recalculate_vision(self)
	tile_occupied.emit()
	
	if is_first:
		for _Unit in getVisibleUnits():
			Units.Vision.on_recalculate_vision(_Unit)

var Killer: UnitGD
func stats(stat_type: String, val: int, AppliedBy := AppliedByGD.new("GameEvent"), absolute: bool = false) -> void:
	var current_health: int = health
	var current_speed: int = speed
	var current_attack: int = attack
	var stats_changed: String = stat_type
	
	match stat_type:
		"damage": # Can't be absolute
			stats_changed = "health"
			health = clamp(health - val, 0, max_health)
		"speed":
			if absolute:
				speed = clamp(val, 0, 9)
				max_speed = speed
			else:
				max_speed = clamp(max_speed + val, 0, 9)
				speed = clamp(speed + val, 0, max_speed)
		"attack":
			if absolute: attack = clamp(val, 0, 99)
			else: attack = clamp(attack + val, 0, 99)
		"health":
			if absolute:
				health = clamp(val, 0, 99)
				max_health = health
			else:
				max_health = clamp(max_health + val, 0, 99)
				health = clamp(health + val, 0, max_health)
		"active_speed":
			stats_changed = "speed"
			if absolute:
				speed = clamp(val, 0, max_speed)
			else: speed = clamp(speed + val, 0, max_speed)
		"heal":
			stats_changed = "health"
			health += val
			
	var color: String = onFindStatColor(stats_changed, current_health, current_attack, current_speed)
	if color != "NULL" and current_health > 0:
		Units.LevelUI.UnitStatusOverlord.onUpdateStats(self, stats_changed.capitalize(), color)
		if health == 0: Units.kill_unit(self, AppliedBy)
		elif health < current_health and AppliedBy.type != "Height": Units.hurt_unit(self, AppliedBy)
		
		if Tile in Vision.ally_vision:
			var y_offset: float = height.top / 2
			match stat_type:
				"health": Units.VFX.onCreateStatParticle(health - current_health, "health", Tile, y_offset)
				"attack": Units.VFX.onCreateStatParticle(attack - current_attack, "attack", Tile, y_offset)
				"speed": Units.VFX.onCreateStatParticle(speed - current_speed, "speed", Tile, y_offset)
				"heal": Units.VFX.onCreateStatParticle(health - current_health, "heal", Tile, y_offset)
			
func onFindStatColor(stat_changed: String, chp: int = -1, catt: int = -1, cspd: int = -1) -> String:
	var color := "BASE"
	match stat_changed:
		"health":
			if health == chp: return "NULL"
			if health < max_health: color = "RED"
			elif health > base_card.health: color = "GREEN"
		"attack":
			if attack == catt: return "NULL"
			if attack < base_card.attack: color = "RED"
			elif attack > base_card.attack: color = "GREEN"
		"speed":
			if speed == cspd: return "NULL"
			if speed > base_card.speed: color = "GREEN"
	return color
	
var is_arrive_rotate: bool = false
func on_arrive(in_vision: bool) -> void:
	if in_vision:
		var RotateTween := create_tween()
		RotateTween.tween_property(self, "rotation:y", 2 * TAU, Units.ARRIVE_EFFECT_DELAY_DURATION * 1.2)\
		.as_relative().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		AudioMaster.play_sfx(AudioDict.ARRIVE)

func on_death() -> void:
	Tiles.on_remove_tile_material(Tile, "EmptyTile")
	reparent(Units.Postmortem)
	Vision.on_recalculate_vision()
	visible = false
	is_dead = true
	global_position = Vector3(1024, 1024, 1024)
	await get_tree().create_timer(0.001).timeout
	
func on_spectated_in_player_phase(state: bool) -> void:
	Units.LevelUI.UnitStatusOverlord.onUnitSpectated(self, state)
	Model.onSetOutlineProperties(state)
	Units.LevelUI.on_update_vision()
	if turn_status == "TurnUsed": Units.setPastPath(self, state)
	Model.static_body.collision_layer = 0 if state else 4
	
func on_enemy_in_range(state: bool) -> void:
	Units.LevelUI.UnitStatusOverlord.onEnemyInRange(self, state)
	Model.onSetOutlineProperties(state)
	Tiles.setTileOutline(Tile, "EnemyInRange", !state)

var visible_tiles: Array
@onready var VisionRaycast: RayCast3D = $VisionRaycast
const RAY_COUNT: int = 20
const RAY_DISTANCE: int = 50
const VISION_RANGE: int = 5

var past_path_set: bool = false
var past_path_info: Dictionary = {} # TileGD: [rot, [nums]]
var past_path_counter: int = 0
var height_adjacent_tiles: Array = []
func onCircleRay() -> void:
	
	visible_tiles = []
	_visible_tiles = {}
	var tiles: Array = Tiles.onTilesInVisionRange(Tile, VISION_RANGE)
	
	for _Tile in tiles:
		if onRayTile(_Tile):
			onAddTileToVisibleTiles(_Tile)
	
	var units: Array = Units.all_units().filter(func(x: UnitGD): return x != self and x.Tile in tiles and x.Tile not in visible_tiles)
	for Unit in units:
		for point in Unit.Model.onGetAdjustedPoints():
			VisionRaycast.target_position = point - VisionRaycast.global_position
			VisionRaycast.force_raycast_update()
			
			if VisionRaycast.is_colliding():
				var Collision: Node3D = VisionRaycast.get_collider().get_node("../../..")
				if Collision == Unit.Model:
					onAddTileToVisibleTiles(Unit.Tile)
					break
	
	visible_tiles += Units.getCommutativeUnitsVision(self)
	onUnitsHeightAdjacentTiles()
	visible_tiles = _visible_tiles.keys()
	
func onRayEnemyUnit(Unit: UnitGD, override: bool = false) -> bool:
	if !override and Unit.Tile in visible_tiles or Unit.Tile in Vision.spawn_tiles: return true
	for point in Unit.Model.onGetAdjustedPoints():
		VisionRaycast.target_position = point - VisionRaycast.global_position
		VisionRaycast.force_raycast_update()
		
		if VisionRaycast.is_colliding():
			var Collision: Node3D = VisionRaycast.get_collider().get_node("../../..")
			if Collision == Unit.Model or Collision == Unit.Tile: return true
	return false
	
func onRayTile(_Tile: TileGD) -> bool:
	for point in _Tile.collision_points:
		VisionRaycast.target_position = point - VisionRaycast.global_position
		VisionRaycast.force_raycast_update()
		
		if VisionRaycast.is_colliding():
			var Collision: Node3D = VisionRaycast.get_collider().get_node("../../../..")
			if Collision == _Tile: return true
	return false
	
var _visible_tiles: Dictionary = {}
func onAddTileToVisibleTiles(_Tile: TileGD) -> void:
	for type in ["obj", "wdeco", "tdeco"]:
		if _Tile[type].multi_tile.size() > 0:
			if _Tile.solid_status == 1:
				for __Tile in _Tile[type].multi_tile:
					_onAddTileToVisibleTiles(__Tile)
	_onAddTileToVisibleTiles(_Tile)
	
func _onAddTileToVisibleTiles(_Tile: TileGD) -> void:
	_visible_tiles.merge({_Tile: null})
	for __Tile in _Tile.top_of_cliff_wall:
		_visible_tiles.merge({__Tile: null})
	
func onUnitsHeightAdjacentTiles() -> void:
	height_adjacent_tiles = []
	if Tile.w > 0:
		for direction in Tiles.cube_directions:
			var pos: Vector3 = Tile.tpos + direction
			if Tiles.position_to_tile(Vector4(pos.x, pos.y, pos.z, Tile.w)) == null:
				for w in range(Tile.w - 1, -1, -1):
					var _Tile: TileGD = Tiles.position_to_tile(Vector4(pos.x, pos.y, pos.z, w))
					if _Tile != null and _Tile.tile.id > 0:
						height_adjacent_tiles.append(_Tile)
						onAddTileToVisibleTiles(_Tile)
						break

func getVisibleUnits() -> Array:
	var visible_units: Array = visible_tiles.map(func(x: TileGD): return Units.unit_by_tile(x))
	return visible_units.filter(func(x: Variant): return x != null and !x.is_queued_for_deletion() and x != self and x.health > 0)

func getVisibleEnemies() -> Array:
	return getVisibleUnits().filter(Units.on_match_team_relation.bind(team, "Enemy"))

func getVisibleAllies() -> Array:
	return getVisibleUnits().filter(Units.on_match_team_relation.bind(team, "Ally"))

func onResetUnit(default_position, default_rot, default_tile) -> void:
	global_position = default_position
	Model.rot = default_rot
	Tile = default_tile
	Model.on_set_rotation()

func isHealable() -> bool:
	return health < max_health

func getAttackAnimation() -> String:
	if Units.GameEffects.onGameFXExists(self, "AbilityActive"):
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
	past_path_info[Tile][0].append(Units.Tiles.neighbour_rotation(_Tile, Tile))
	past_path_info[Tile][1].append(past_path_counter)
