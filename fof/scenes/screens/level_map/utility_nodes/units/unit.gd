class_name UnitGD
extends Node3D

var is_dead: bool = false
var id: int = 0
var tool_id: int = 0
var effects: Array = []
var unit_fx: Array = []
var is_spectated: bool = false
var visible_state: bool = false

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
func onUnitAwakened(_id: int, _tool_id: int, _effects: Array, _team: int, rot: int, tile: TileGD) -> void:
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
		"stat": base_card.stat
	}
	
	var card_model_path: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/model.tscn"
	
	Model = load(card_model_path).instantiate() # Takes about 2.2seconds, not the ready function?
	Model.Unit = self
	Model.rot = rot
	add_child(Model)
	
	VisionRaycast.position.y = height.eye
	
	position = tile.position
	position.y += 0.3 if !Units.Tiles.is_ramp_tile(tile) else 0.9
	if team == 1: Model.setVisible(false)
	AudioDict = load("res://assets/base_game/cards/cards/" + base_card.folder_name + "/audio.tres")
	onCreateAbilities()

func onCreateAbilities() -> void:
	var DIR_PATH: String = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/abilities/"
	if DirAccess.dir_exists_absolute(DIR_PATH):
		for ability_name in Array(DirAccess.get_files_at(DIR_PATH)).filter(func(x: String): return x.ends_with(".tres")):
			var ability: AbilityGD = load(DIR_PATH + ability_name).duplicate()
			ability.VFX = Units.VFX
			ability.SpectateCamera = Units.SpectateCamera
			ability.Units = Units
			ability.Tiles = Tiles
			ability.Vision = Vision
			ability.Combat = Units.Combat
			ability.LevelUI = Units.LevelUI
			ability.GameEffects = Units.GameEffects
			ability.LevelMap = Units.LevelMap
			ability.charges = ability.max_charges
			abilities.append(ability)
			
			if ability is ArmorGD: onAddUnitFX("Armor", ability.armor)
			elif ability is TargetAbilityGD or ability is OngoingAbilityGD: ability.setInfo(self)
			
func onAddUnitFX(type: String, charges: int = -1) -> void:
	var info_fx: InfoFXGD = load(Units.LevelUI.UnitStatusOverlord.all_info_fx[type])
	info_fx.charges = charges
	unit_fx.append(info_fx)
		
var vision_info_array: Array = []

func occupy_tile(_Tile: TileGD) -> void:
	Tile = _Tile
	if vision_info_array.is_empty(): Vision.onRecalculateVision(self)
	else: Vision.onRecalculateVisionPrecalculated(self, vision_info_array.pop_front())
	
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
		
		if Tile in Vision.getTeamVision():
			var y_offset: float = height.top / 2
			match stat_type:
				"health": Units.VFX.onCreateStatParticle(health - current_health, "health", Tile, y_offset)
				"attack": Units.VFX.onCreateStatParticle(attack - current_attack, "attack", Tile, y_offset)
				"speed": Units.VFX.onCreateStatParticle(speed - current_speed, "speed", Tile, y_offset)
				"heal": Units.VFX.onCreateStatParticle(health - current_health, "heal", Tile, y_offset)
	Units.Combat.onOngoingAbility(self, "ChangeStat", [AppliedBy, stats_changed])
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
	visible = false
	is_dead = true
	global_position = Vector3(1024, 1024, 1024)
	await get_tree().process_frame
	
func on_spectated_in_player_phase(state: bool) -> void:
	Units.LevelUI.UnitStatusOverlord.onUnitSpectated(self, state)
	Model.onSetOutlineProperties(state)
	Units.LevelUI.on_update_vision()
	if turn_status == "TurnUsed": Units.setPastPath(self, state)
	is_spectated = state
	setCollisionLayerSpectated()
	
func setCollisionLayerSpectated() -> void:
	Model.static_body.collision_layer = 4 if (is_spectated or !visible_state) else 36
	
func on_enemy_in_range(state: bool) -> void:
	Units.LevelUI.UnitStatusOverlord.onEnemyInRange(self, state)
	Model.onSetOutlineProperties(state)
	Tiles.setTileOutline(Tile, "EnemyInRange", !state)

var visible_tiles: Array
@onready var VisionRaycast: RayCast3D = $VisionRaycast
const VISION_RANGE: int = 5

var past_path_set: bool = false
var past_path_info: Dictionary = {} # TileGD: [rot, [nums]]
var past_path_counter: int = 0

func onCalculateVisionInfo() -> Dictionary:
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
		onRemoveNonCommutativeUnits(_visible_tiles)
		onUnitsHeightAdjacentTiles(_visible_tiles)
	
	return {"visible_tiles": _visible_tiles, "unit_vision": onCalculateUnitVision(_visible_tiles)}
	
func onCalculateEnemyUnitCommutative(Unit: UnitGD) -> bool:
	if Unit.Tile in visible_tiles: return true
	for point in Unit.Model.onGetAdjustedPoints() + Unit.Tile.collision_points:
		VisionRaycast.target_position = (point - VisionRaycast.global_position) * 1.05
		VisionRaycast.force_raycast_update()
		
		if VisionRaycast.is_colliding():
			var Collision: Node3D = VisionRaycast.get_collider().get_node("../../../..")
			if Collision == Unit: return true
	return false

func onRemoveNonCommutativeUnits(_visible_tiles: Array) -> void:
	for Unit in Units.all_units(self):
		if Unit.Tile in _visible_tiles and Unit.Tile not in Vision.spawn_tiles and !(Unit.onCalculateEnemyUnitCommutative(self)):
			_visible_tiles.erase(Unit.Tile)

func onCalculateUnitVision(_visible_tiles: Array = []) -> Dictionary:
	var intent: Dictionary = {}
	for _Unit in Units.all_units(self):
		var isvisible: bool = _Unit.Tile in _visible_tiles
		var wasvisible: bool = _Unit.Tile in visible_tiles
		if (isvisible and !wasvisible): intent[_Unit] = "Enter"
		elif (wasvisible and !isvisible): intent[_Unit] = "Exit"
		elif (!isvisible and !wasvisible): intent[_Unit] = "Invisible"
		else: intent[_Unit] = "Regular"
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
	Tile = default_tile
	Model.onSetCollisionRotation()

func isHealable() -> bool:
	return health < max_health

func getAttackAnimation() -> String:
	if Units.GameEffects.onGameFXExists(self, GameFXGD.ABILITY_ACTIVE):
		return "AttackAbility"
	return "Attack"
	
func getVisibleTiles() -> Array: # Removes tile unit is on
	return visible_tiles.filter(func(x: TileGD): return x != Tile)

func setExtraDamage(x: int = 0) -> void:
	extra_damage = x
	print(x)

func setHealMultiplier(x: int = 1) -> void:
	heal_multiplier = x

func onAddToPastPath(_Tile: TileGD) -> void:
	past_path_counter += 1
	if !past_path_info.has(Tile): past_path_info[Tile] = [[], []]
	past_path_info[Tile][0].append(Units.Tiles.neighbour_rotation(_Tile, Tile))
	past_path_info[Tile][1].append(past_path_counter)

func setVisibleState(state: bool) -> void:
	visible_state = state
	setCollisionLayerSpectated()
