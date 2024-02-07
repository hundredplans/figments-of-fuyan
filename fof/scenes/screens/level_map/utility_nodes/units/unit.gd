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
	
	Model.on_add_model()
	occupy_tile(tile)
	position = tile.position
	position.y += 0.3
	rotation_degrees.y = (rot * 60) + 30

func occupy_tile(_Tile: TileGD) -> void:
	if Tile != null: Tile.solid_status = Tile.original_solid_status
	
	Tile = _Tile
	Tile.original_solid_status = Tile.solid_status
	Tile.solid_status = 1
	Vision.on_recalculate_vision()

func stats(stat_type: String, val: int, absolute: bool = false) -> void:
	match stat_type:
		"speed":
			if absolute:
				speed = val
			else: speed += val
		"attack":
			if absolute:
				attack = val
			else: attack += val
		"health":
			if absolute: 
				health = val
			else: health += val
				
	UnitStatus.on_reset_stats()

func status_effect() -> void:
	pass
