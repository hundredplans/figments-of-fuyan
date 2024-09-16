extends MapEffectGD

var rarity: Game.Rarities
var type: GDScript

func onSave() -> SavedData:
	return SavedDataMapEffectGainFofObject.new(info.id, false, rarity, type)

func onLoadData(data: SavedData) -> void:
	super(data)
	type = data.type
	rarity = data.rarity

func getDescription() -> String:
	return Helper.getDescription(info.description, [Game.getRarityString(rarity).to_lower(), type.getFofName()])
