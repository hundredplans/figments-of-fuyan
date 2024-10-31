class_name ActiveEffectUsedAction extends Action

var ActiveEffect: ActiveEffectDatastore
var Tile: TileGD
var active_effect_tiles: ActiveEffectTiles

func _init(_ActiveEffect: ActiveEffectDatastore = null, _Tile: TileGD = null, _active_effect_tiles: ActiveEffectTiles = null) -> void:
	super()
	ActiveEffect = _ActiveEffect
	Tile = _Tile
	active_effect_tiles = _active_effect_tiles
	
func onPreAction() -> void:
	ActiveEffect.owner.onActiveEffectPre(ActiveEffect, Tile, active_effect_tiles)
	
func onPostAction() -> void:
	ActiveEffect.owner.onActiveEffect(ActiveEffect, Tile, active_effect_tiles)
	var actions: Array = [
		ChangeActiveEffectChargesAction.new(ActiveEffect, -1),
		ChangeActiveEffectUsedAction.new(ActiveEffect, true)]
	onPushAction(actions)

func getDelay() -> float:
	return ActiveEffect.delay if ActiveEffect.owner.getLevelVisible() else 0
	
func getLogInfo() -> Array:
	return ["ActiveEffect: " + ActiveEffect.name]
