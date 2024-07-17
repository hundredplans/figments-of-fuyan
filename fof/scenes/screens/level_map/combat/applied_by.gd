class_name AppliedByGD
extends Resource

var type: String = "GameEvent"

# Can be an IObject, Unit, Tool, Boon, Tile
var Applier: Variant

func _init(_type: String = "GameEvent", _Applier: Variant = null) -> void:
	Applier = _Applier
	type = _type

enum {
	ABILITY,
	DUMSY_PALMSY_ARRIVE,
	TOOL,
	MOVEMENT_FINISHED,
	ATTACK,
	BOON,
	DEEP_WATER,
	IOBJECT,
	START_AI_PHASE,
	END_AI_PHASE,
	TRAIT,
	HEIGHT,
	GAME_EVENT,
	START_PLAYER_PHASE,
	END_PLAYER_PHASE
}
