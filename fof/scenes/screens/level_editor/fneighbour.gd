class_name FneighbourGD
extends Resource

var Tile: TileGD
@export var id: int
@export var movement_type: int = UNPASSABLE
@export var unit_height: float
@export var hdiff: int
@export var is_solid: bool = false

# Can be a Unit or a DObjectGD, handled differently in each case
var AttackTarget: Variant

enum {
	UNPASSABLE,
	REGULAR,
	RAMP,
	JUMP,
	FALL,
	HIGH,
	ATTACK_DOBJECT,
}


func _init(_id: int = 0, _movement_type: int = UNPASSABLE, _unit_height: float = 0, _hdiff: int = 0, _is_solid: bool = false) -> void:
	id = _id
	movement_type = _movement_type
	unit_height = _unit_height
	hdiff = _hdiff
	is_solid = _is_solid

func changeIsSolid(x: bool) -> void:
	if !x: movement_type = REGULAR
	else: movement_type = UNPASSABLE
	is_solid = x

func isAttack() -> bool: return AttackTarget != null
