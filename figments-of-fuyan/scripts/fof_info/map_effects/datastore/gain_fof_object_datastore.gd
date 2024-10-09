class_name GainFofObjectDatastore extends MapEffectDatastore

const id: int = 1
enum TYPES {BOON, TOOL, CARD}
@export var rarity: Game.Rarities
@export var type: TYPES

func getType() -> GDScript:
	match type:
		TYPES.BOON: return BoonInfo
		TYPES.TOOL: return ToolInfo
		TYPES.CARD: return CardInfo
	return null

func getSavedData() -> SavedDataMapEffect:
	return SavedDataMapEffectGainFofObject.new(id, false, 0, rarity, getType())
