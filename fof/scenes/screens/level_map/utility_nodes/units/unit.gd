class_name UnitGD
extends Node3D

var UnitStatus: Control
var id: int = 0
var tool_id: int = 0
var effects: Array = []

var base_card: Dictionary

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
var Units: UnitsGD
var Tiles: TilesGD
var TeamControl: Node

var turn_status: int = 0 # 0 = turn active, 1 = turn inactive, 2 = turn used

@onready var UnitFieldStatus: Node3D = $UnitFieldStatus
@onready var Model: Node3D = $Model
func on_create_unit(_id: int, _tool_id: int, _effects: Array, _team: int, rot: int, tile: TileGD) -> void:
	id = _id
	tool_id = _tool_id
	effects = _effects
	team = _team
	
	base_card = Helper.id_to_dict(id, "Card")
	attack = base_card.a
	health = base_card.h
	max_speed = base_card.s
	
	max_health = base_card.h
	max_attack = base_card.a
	rarity = base_card.r
	height = base_card.height

	TeamControl = load("res://scenes/screens/level_map/utility_nodes/units/Team" + str(team) + ".tscn").instantiate()
	TeamControl.Unit = self
	add_child(TeamControl)
	
	Model.rot = rot
	Model.on_add_model()
	
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
	AudioDict = load("res://assets/base_game/cards/" + base_card.bgfn + "/audio.tres")

func occupy_tile(_Tile: TileGD) -> void:
	Tile = _Tile
	Vision.on_recalculate_vision(self)

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
	if health == 0:
		if typeof(AppliedBy) != TYPE_STRING: Killer = AppliedBy; AppliedBy = "Unit"
		Units.kill_unit(self, AppliedBy)
	elif health < current_health: AudioMaster.play_sfx(AudioDict.HURT)

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
	Tiles.on_remove_tile_material(Tile, "")
	Vision.on_recalculate_vision()
	queue_free()

func on_spectated_in_player_phase(state: bool) -> void:
	UnitStatus.on_unit_spectated(state)
	UnitFieldStatus.on_unit_spectated(state)
	Units.LevelUI.on_update_vision()
	
	if team == 0:
		if state:
			Tiles.on_set_tile_material(Tile, "SpectatingUnit")
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
var visible_units: Array
@onready var VisionRaycast: Node3D = $VisionRaycast
const RAY_COUNT: int = 100
const RAY_DISTANCE: int = 50
const VISION_RANGE: int = 5

func onCircleRay() -> void:
	visible_tiles = []
	var vision_tposes: Array = Tiles.getTposInRange(Tile, VISION_RANGE, true)
	for i in range(RAY_COUNT):
		var phi: float = (i * (PI * 2)) / RAY_COUNT
		var theta: float = 0
		for j in range(RAY_COUNT):
			theta = (j * PI) / RAY_COUNT
			VisionRaycast.target_position = Vector3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta)) * RAY_DISTANCE
			VisionRaycast.force_raycast_update()
			
			if VisionRaycast.is_colliding():
				var Collision: Node3D = VisionRaycast.get_collider().get_node("../../..")
				if Collision is TileGD:
					if Collision.tpos in vision_tposes:
						onAddTileToVisibleTiles(Collision)
				else:
					Collision = Collision.get_parent().get_parent()
					if Collision.Tile.tpos in vision_tposes:
						onAddTileToVisibleTiles(Collision.Tile)
	onUnitsHeightAdjacentTiles()

func onAddTileToVisibleTiles(_Tile: TileGD) -> void:
	if _Tile not in visible_tiles:
		for type in ["obj", "wdeco", "tdeco"]:
			if _Tile[type].multi_tile.size() > 0:
				if _Tile.solid_status == 1:
					for __Tile in _Tile[type].multi_tile:
						if __Tile not in visible_tiles:
							_onAddTileToVisibleTiles(__Tile)
		_onAddTileToVisibleTiles(_Tile)
	
func _onAddTileToVisibleTiles(_Tile: TileGD) -> void:
	visible_tiles.append(_Tile)
	for __Tile in _Tile.top_of_cliff_wall:
		if __Tile not in visible_tiles:
			visible_tiles.append(__Tile)
	
func onUnitsHeightAdjacentTiles() -> void:
	if Tile.w > 0:
		for direction in Tiles.cube_directions:
			var pos: Vector3 = Tile.tpos + direction
			if Tiles.position_to_tile(Vector4(pos.x, pos.y, pos.z, Tile.w)) == null:
				for w in range(Tile.w - 1, -1, -1):
					var _Tile: TileGD = Tiles.position_to_tile(Vector4(pos.x, pos.y, pos.z, w))
					if _Tile != null and _Tile.tile.id > 0:
						onAddTileToVisibleTiles(_Tile)
						break
