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
var height: int
var Tile: TileGD

var attack_range: int = 1
var attack_amount: int = 0

var AudioDict: AudioDictGD
var Vision: VisionGD
var Units: UnitsGD
var TeamControl: Node
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
	occupy_tile(tile)
	position = tile.position
	position.y += 0.3
	
	AudioDict = load("res://assets/base_game/cards/" + base_card.bgfn + "/audio.tres")

func occupy_tile(_Tile: TileGD) -> void:
	if Tile != null: Tile.solid_status = Tile.original_solid_status
	
	Tile = _Tile
	Tile.original_solid_status = Tile.solid_status
	Tile.solid_status = 1
	Vision.on_recalculate_vision()

func stats(stat_type: String, val: int, AppliedBy: UnitGD = null, absolute: bool = false) -> void:
	if absolute: val = max(val, 0)
	match stat_type:
		"speed":
			if absolute:
				speed = val
			else: speed = max(speed + val, 0)
		"attack":
			if absolute:
				attack = val
			else: attack = max(attack + val, 0)
		"health":
			if absolute: 
				health = val
			else: health = max(health + val, 0)
				
	UnitStatus.on_reset_stats()
	if health == 0: Units.kill_unit(self, AppliedBy)

func status_effect() -> void:
	pass

const ARRIVE_EFFECT_LIGHT_DURATION: float = 1.2
const ARRIVE_EFFECT_INITIAL_LIGHT_ENERGY: float = 3

func on_arrive(in_vision: bool) -> void:
	if in_vision:
		var Light := OmniLight3D.new()
		add_child(Light)
		Light.position.y = height * 1.2
		Light.light_energy = ARRIVE_EFFECT_INITIAL_LIGHT_ENERGY
		Light.light_color = Helper.rarity_colors[rarity]
		var LightTween: Tween = get_tree().create_tween()
		LightTween.tween_property(Light, "light_energy", 0, ARRIVE_EFFECT_LIGHT_DURATION)
		LightTween.finished.connect(func(): Light.queue_free())
		AudioMaster.play_sfx(AudioDict.ARRIVE)
	# can do regular arrive effects here

func on_death() -> void:
	queue_free()
	UnitStatus._queue_free()
