@tool
class_name BoonInfoGD extends Resource

static var INFO_PATH: String = "res://resources/game/boons/"
@export var id: int
@export var name: String
@export_multiline var description: String
@export var gdscript: GDScript
@export var RARITY: RARITIES

enum RARITIES {SCRAP, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}

func _init() -> void:
	id = StaticHelper.onAutoIncrementID(BoonInfoGD, id)
