@tool
class_name EncounterInfoGD
extends Resource

static var INFO_PATH: String = "res://resources/game/encounters/"
@export var id: int
@export var name: String
@export var branch: BranchInfoGD
@export var can_occur_randomly: bool = true

func _init() -> void:
	id = StaticHelper.onAutoIncrementID(EncounterInfoGD, id)
