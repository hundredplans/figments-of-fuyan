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
	
	UnitFieldStatus.Unit = self
	UnitFieldStatus.SpectateCamera = Units.SpectateCamera
	UnitFieldStatus.unit_set = true
	UnitFieldStatus.position.y = height.top + 0.05
	UnitFieldStatus.on_set_unit()
	
	position = tile.position
	position.y += 0.3
	occupy_tile(tile)
	Units.Tiles.on_set_tile_material(tile, "AllyOccupy" if team == 0 else "EnemyOccupy")
	AudioDict = load("res://assets/base_game/cards/" + base_card.bgfn + "/audio.tres")

func occupy_tile(_Tile: TileGD) -> void:
	var old_tile_state: Array = []
	if Tile != null: 
		old_tile_state = Tile.tile_state.duplicate()
		Units.Tiles.on_remove_tile_material(Tile, "UnitChangeTile")
	
	Tile = _Tile
	Tile.tile_state = old_tile_state
	Units.Tiles.on_set_tile_highest_material(Tile, "")

	Vision.on_recalculate_vision()

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
		var LightTween: Tween = get_tree().create_tween()
		LightTween.tween_property(Light, "light_energy", 0, ARRIVE_EFFECT_LIGHT_DURATION)
		LightTween.finished.connect(func(): Light.queue_free())
		AudioMaster.play_sfx(AudioDict.ARRIVE)
	# can do regular arrive effects here

func on_death() -> void:
	Units.Tiles.on_remove_tile_material(Tile, "")
	queue_free()

var units_in_vision: Array
func on_spectated_in_player_phase(state: bool) -> void:
	UnitStatus.on_unit_spectated(state)
	UnitFieldStatus.on_unit_spectated(state)
	if state:
		Units.Tiles.on_set_tile_material(Tile, "SpectatingUnit")
		Units.LevelUI.on_update_vision()
	else: Units.Tiles.on_remove_tile_material(Tile, "SpectatingUnit")

func on_set_turn_status() -> void:
	UnitStatus.SlotOne.visible = turn_status == 2
	UnitFieldStatus.SlotOne.visible = turn_status == 2
	if turn_status == 0: UnitStatus.on_set_status_box_modulate("TurnActive")
	
func on_enemy_in_range(state: bool) -> void:
	UnitStatus.SlotOne.visible = state
	UnitFieldStatus.SlotOne.visible = state
	if state:
		Units.Tiles.on_set_tile_material(Tile, "EnemyInRange")
