class_name ActiveEffectUsedAction extends Action

var ActiveEffect: ActiveEffectDatastore
var Tile: TileGD

func _init(_ActiveEffect: ActiveEffectDatastore = null, _Tile: TileGD = null) -> void:
	super()
	ActiveEffect = _ActiveEffect
	Tile = _Tile
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	ActiveEffect.owner.onActiveEffect(ActiveEffect, Tile)

func getDelay() -> float:
	return super()
