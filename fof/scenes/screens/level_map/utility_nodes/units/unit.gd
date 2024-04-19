class_name UnitGD
extends Node3D

var UnitStatus: Control
var id: int = 0
var tool_id: int = 0
var effects: Array = []

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
var attack_amount: int = 0

var AudioDict: AudioDictGD
var Vision: VisionGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Tiles: TilesGD
var TeamControl: Node

var turn_status: int = 0 # 0 = turn active, 1 = turn inactive, 2 = turn used
var finished_awakening: bool = false

@onready var UnitFieldStatus: Node3D = $UnitFieldStatus
@onready var Model: Node3D

func on_create_unit(_id: int, _tool_id: int, _effects: Array, _team: int, rot: int, tile: TileGD) -> void:
	id = _id
	tool_id = _tool_id
	effects = _effects
	team = _team
	
	var card: Variant = Helper.getCard(id)
	if card is HeroCardGD: base_card = card.base_cards[Units.GameState.hero_level]
	else: base_card = card
	
	ai = {"aic": base_card.aic, "aii": base_card.aii, "aiw": base_card.aiw, "ait": base_card.ait, "aia": base_card.aia}
	attack = base_card.attack
	health = base_card.health
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
	UnitFieldStatus.Unit = self
	UnitFieldStatus.SpectateCamera = Units.SpectateCamera
	UnitFieldStatus.unit_set = true
	UnitFieldStatus.position.y = height.stat
	UnitFieldStatus.on_set_unit()
	
	position = tile.position
	position.y += 0.3
	occupy_tile(tile)
	Tiles.on_set_tile_material(tile, "AllyOccupy" if team == 0 else "EnemyOccupy")
	AudioDict = load("res://assets/base_game/cards/cards/" + base_card.folder_name + "/audio.tres")

func occupy_tile(_Tile: TileGD) -> void:
	Vision.onExitTile(self, Tile, _Tile)
	Tile = _Tile
	Vision.on_recalculate_vision(self)
	Model.onGetAdjustedPoints()

var Killer: UnitGD
func stats(stat_type: String, val: int, AppliedBy: Variant = "GameEvent", absolute: bool = false) -> void:
	var current_health: int = health
	var stats_changed: String = ""
	if absolute: val = clamp(val, 0, 99)
	match stat_type:
		"speed":
			if speed != val: stats_changed = stat_type
			if absolute:
				speed = clamp(val, 0, 9)
			else: speed = clamp(speed + val, 0, 9)
		"attack":
			if attack != val: stats_changed = stat_type
			if absolute:
				attack = val
			else: attack = clamp(attack + val, 0, 99)
		"health":
			if health != val: stats_changed = stat_type
			if absolute: 
				health = val
			else: health = clamp(health + val, 0, 99)
				
	UnitStatus.on_reset_stats(stats_changed)
	
	var applied_by_string: String = ""
	if typeof(AppliedBy) != TYPE_STRING: applied_by_string = "Unit"
	else: applied_by_string = AppliedBy
	
	if health == 0:
		if applied_by_string == "Unit": Killer = AppliedBy
		Units.kill_unit(self, applied_by_string)
	elif health < current_health and applied_by_string != "Height": Units.hurt_unit(self, AppliedBy)

func status_effect() -> void:
	pass

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
	Vision.on_recalculate_vision()
	queue_free()

func on_spectated_in_player_phase(state: bool) -> void:
	UnitStatus.on_unit_spectated(state)
	UnitFieldStatus.on_unit_spectated(state)
	Units.LevelUI.on_update_vision()
	
	if team == 0:
		if state: Tiles.on_set_tile_material(Tile, "SpectatingUnit")
		else: Tiles.on_remove_tile_material(Tile, "SpectatingUnit")

func on_set_turn_status() -> void:
	UnitStatus.SlotOne.visible = turn_status == 2
	UnitFieldStatus.SlotOne.visible = turn_status == 2
	if turn_status == 0: UnitStatus.on_set_status_box_modulate("TurnActive")
	
func on_enemy_in_range(state: bool) -> void:
	UnitStatus.SlotOne.visible = state
	UnitFieldStatus.SlotOne.visible = state
	if state:
		Tiles.on_set_tile_material(Tile, "EnemyInRange")

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
	
func onRayEnemyUnit(Unit: UnitGD) -> bool:
	if Unit.Tile in visible_tiles or Unit.Tile in Vision.spawn_tiles: return true
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
	return visible_tiles.map(func(x: TileGD): return Units.unit_by_tile(x)).filter(func(x: Variant): return x != null)

func getVisibleEnemies() -> Array:
	return getVisibleUnits().filter(Units.on_match_team_relation.bind(team, "Enemy"))

func onResetUnit(default_position, default_rot, default_tile) -> void:
	global_position = default_position
	Model.rot = default_rot
	Tile = default_tile
	Model.on_set_rotation()
