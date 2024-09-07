class_name NextShopTypeCheaperDatastore extends MapEffectDatastore

const id: int = 3
@export_range(0, 1, 0.01) var cheaper_percentage: float
@export var type: Game.ShopTypes

func onRandomise() -> void:
	type = Game.ShopTypes.values().pick_random()

func getSavedData() -> SavedDataMapEffectNextShopTypeCheaper:
	return SavedDataMapEffectNextShopTypeCheaper.new(id, cheaper_percentage, type)
	
