class_name AppliedByGD
extends Resource

var type: int

# Can be an IObject, Unit, Tool, Boon, Tile
var Applier: Variant

func _init(_type: int = 0, _Applier: Variant = null) -> void:
	Applier = _Applier
	type = _type

func getUnit() -> UnitGD:
	if Applier is UnitGD: return Applier
	return null

enum {
	GAME_EVENT,
	ABILITY,
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
	START_PLAYER_PHASE,
	END_PLAYER_PHASE,
	HELPFUL_HELMET,
	CONSOLE,
	DOBJECT,
	TRINKET
}
