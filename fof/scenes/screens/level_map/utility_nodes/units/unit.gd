class_name UnitGD
extends Node3D

var id: int = 0
var tool_id: int = 0
var effects: Array = []

var base_card: Dictionary
var a: int
var h: int
var s: int
var mh: int
var r: int
var team: int

var TeamControl: Node
@onready var Model: Node3D = $Model
func on_create_unit(_id: int, _tool_id: int, _effects: Array, _team: int, rot: int, pos: Vector3) -> void:
	id = _id
	tool_id = _tool_id
	effects = _effects
	team = _team
	
	base_card = Helper.id_to_dict(id, "Card")
	a = base_card.a
	h = base_card.h
	s = base_card.s
	mh = base_card.h
	r = base_card.r

	TeamControl = load("res://scenes/screens/level_map/utility_nodes/units/Team" + str(team) + ".tscn").instantiate()
	add_child(TeamControl)
	
	Model.on_add_model()
	position = pos
	position.y += 0.3
	rotation_degrees.y = rot * 60
