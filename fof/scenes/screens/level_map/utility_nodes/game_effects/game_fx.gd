class_name GameFXGD
extends Resource

var type: int
var info: Dictionary
var triggers: Array = []
var Unit: UnitGD

enum {HEAL_NEXT_TURN, BUFF_NEXT_TURN, DAZE, STAGGER, ABILITY_ACTIVE, HELPFUL_HELMET, CHARMING_STANCE,
	COCUS_POCUS}

func _init(_Unit: UnitGD = null, _type: int = -1, _info: Dictionary = {}, _triggers: Array = []) -> void:
	if _type == -1: push_error("Your game_fx type is invalid!")
	Unit = _Unit
	type = _type
	info = _info
	triggers = _triggers
