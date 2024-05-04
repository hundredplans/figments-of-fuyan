class_name UnitGD
extends Node3D

signal tile_occupied

var id: int = 0
var tool_id: int = 0
var effects: Array = []
var unit_fx: Array = []

var hero_card: HeroCardGD
var base_card: BaseCardGD
var ai: Dictionary

var max_attack: int
var attack: int

var max_speed: int
var speed: int

var max_health: int
var health: int

var rarity: int
var team: int
var height: Dictionary
var Tile: TileGD

var attack_range: int = 1
var attack_amount: int = 1

var AudioDict: AudioDictGD
var Vision: VisionGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Tiles: TilesGD
var TeamControl: Node

var turn_status: String = "TurnUnused"
var finished_awakening: bool = false
var abilities: Array = []
var base_text: String

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
	max_attack = base_card.attack
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
			abilities.append(ability)
			
			if ability is ArmorGD:
				onAddUnitFX("Armor", ability.armor)
			
func onAddUnitFX(type: String, charges: int = -1) -> void:
	unit_fx.append([type, charges])
		
func occupy_tile(_Tile: TileGD) -> void:
	var OGTile: TileGD = Tile
	Tile = _Tile
	
	await get_tree().create_timer(0.001).timeout
	Vision.onExitTile(self, OGTile, _Tile)
	Vision.on_recalculate_vision(self) # Takes up to 60msec, this gets stacked and it gets bad lag (threads?)
	tile_occupied.emit()

var Killer: UnitGD
func stats(stat_type: String, val: int, AppliedBy := AppliedByGD.new(), absolute: bool = false) -> void:
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
			if absolute:
				attack = clamp(val, 0, 99)
				max_attack = attack
			else:
				max_attack = clamp(max_attack + val, 0, 99)
				attack = clamp(attack + val, 0, max_attack)
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
			
	var stat_updated: bool = false
	var color := "BASE"
	match stats_changed:
		"health":
			stat_updated = health != current_health
			if health < max_health: color = "RED"
			elif health > base_card.health: color = "GREEN"
		"attack":
			stat_updated = attack != current_attack
			if attack < max_attack: color = "RED"
			elif health > base_card.speed: color = "GREEN"
		"speed":
			stat_updated = speed != current_speed
			if speed > base_card.speed: color = "GREEN"
			
	if stat_updated:
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

const ARRIVE_EFFECT_LIGHT_DURATION: float = 1.2
const ARRIVE_EFFECT_INITIAL_LIGHT_ENERGY: float = 3

func on_arrive(in_vision: bool) -> void:
	if in_vision:
		var Light := OmniLight3D.new()
		add_child(Light)
		Light.position.y = height.top * 1.2
		Light.light_energy = ARRIVE_EFFECT_INITIAL_LIGHT_ENERGY
		Light.light_color = Helper.rarity_colors[rarity]
		var LightTween: Tween = create_tween()
		LightTween.tween_property(Light, "light_energy", 0, ARRIVE_EFFECT_LIGHT_DURATION)
		LightTween.finished.connect(func(): Light.queue_free())
		AudioMaster.play_sfx(AudioDict.ARRIVE)
	# can do regular arrive effects here

func on_death() -> void:
	Tiles.on_remove_tile_material(Tile, "EmptyTile")
	queue_free()
	Vision.on_recalculate_vision()

func on_spectated_in_player_phase(state: bool) -> void:
	Units.LevelUI.UnitStatusOverlord.onUnitSpectated(self, state)
	Model.onSetOutlineProperties(state)
	Units.LevelUI.on_update_vision()
	
func on_enemy_in_range(state: bool) -> void:
	Units.LevelUI.UnitStatusOverlord.onEnemyInRange(self, state)
	Model.onSetOutlineProperties(state)
	if state: Tiles.setTileOutline(Tile, "EnemyInRange")

var visible_tiles: Array
@onready var VisionRaycast: RayCast3D = $VisionRaycast
const RAY_COUNT: int = 20
const RAY_DISTANCE: int = 50
const VISION_RANGE: int = 5

var height_adjacent_tiles: Array = []
func onCircleRay() -> void:
	visible_tiles = []
	_visible_tiles = {}
	var tiles: Array = Tiles.onTilesInVisionRange(Tile, VISION_RANGE)
	for _Tile in tiles: # Takes between 20-30 msec
		if onRayTile(_Tile): onAddTileToVisibleTiles(_Tile)
	
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
			var Collision: Node3D = VisionRaycast.get_collider().get_node("../../..")
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
	return visible_tiles.map(func(x: TileGD): return Units.unit_by_tile(x)).filter(func(x: Variant): return x != null and !x.is_queued_for_deletion() and x != self and x.health > 0)

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
