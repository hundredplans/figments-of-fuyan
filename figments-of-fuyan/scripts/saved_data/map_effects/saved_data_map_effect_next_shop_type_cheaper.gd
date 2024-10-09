class_name SavedDataMapEffectNextShopTypeCheaper extends SavedDataMapEffect

@export var cheaper_percentage: float
@export var type: Game.ShopTypes

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _cheaper_percentage: float = 0, _type: Game.ShopTypes = Game.ShopTypes.CARD) -> void:
	super(_id, _first_init, _public_id)
	cheaper_percentage = _cheaper_percentage
	type = _type
