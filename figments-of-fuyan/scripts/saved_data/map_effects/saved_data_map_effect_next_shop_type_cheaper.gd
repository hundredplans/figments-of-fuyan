class_name SavedDataMapEffectNextShopTypeCheaper extends SavedDataMapEffect

@export var cheaper_percentage: float
@export var type: Game.ShopTypes

func _init(_id: int = 0, _first_init: bool = false, _cheaper_percentage: float = 0, _type: Game.ShopTypes = Game.ShopTypes.CARD) -> void:
	super(_id, _first_init)
	cheaper_percentage = _cheaper_percentage
	type = _type
