@tool
class_name AreaInfoGD extends Resource

static var INFO_PATH: String = "res://resources/game/areas/"
@export var id: int
@export var name: String
@export var card_background: Image
# Which units are considered part of the area
@export var units: Array[UnitInfoGD]
@export var overworld: PalmLevelInfoGD
@export var base_environment: Environment
@export var late_environment: Environment

func _init() -> void:
	id = StaticHelper.onAutoIncrementID(AreaInfoGD, id)
