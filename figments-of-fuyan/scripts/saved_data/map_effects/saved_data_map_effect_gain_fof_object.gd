class_name SavedDataMapEffectGainFofObject extends SavedDataMapEffect

@export var rarity: Game.Rarities
@export var type: GDScript

func _init(_id: int = 0, _rarity: Game.Rarities = Game.Rarities.SCRAP, _type: GDScript = null) -> void:
	super(_id)
	rarity = _rarity
	type = _type
