extends MapEffectGD

var cheaper_percentage: float
var type: Game.ShopTypes

func onSave() -> SavedData:
	return SavedDataMapEffectNextShopTypeCheaper.new(info.id, false, public_id, cheaper_percentage, type)

func onLoadData(data: SavedData) -> void:
	super(data)
	cheaper_percentage = data.cheaper_percentage
	type = data.type

func getDescription() -> String:
	return Helper.getDescription(info.description, [Game.getShopType(type) + "s", int(cheaper_percentage * 100)])
