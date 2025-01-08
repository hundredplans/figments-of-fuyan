class_name ActiveEffectUsedAction extends Action

var ActiveEffect: ActiveEffectDatastore
var Tile: TileGD
var active_effect_tiles: ActiveEffectTiles
var Card: CardGD # Card that triggered, null for Tools and Cards only triggers for iobjects

func _init(_ActiveEffect: ActiveEffectDatastore = null, _Tile: TileGD = null, _active_effect_tiles: ActiveEffectTiles = null, _Card: CardGD = null) -> void:
	super()
	ActiveEffect = _ActiveEffect
	Tile = _Tile
	active_effect_tiles = _active_effect_tiles
	Card = _Card
	
func onPreAction() -> void:
	if ActiveEffect.owner is not IObjectGD: ActiveEffect.owner.onActiveEffectPre(ActiveEffect, Tile, active_effect_tiles)
	else: ActiveEffect.owner.onActiveEffectPre(ActiveEffect, Tile, active_effect_tiles, Card)
	setActionDelay(ActiveEffect.delay if ActiveEffect.owner.isLevelVisible() else 0)
	
func onPostAction() -> void:
	if ActiveEffect.owner is not IObjectGD: ActiveEffect.owner.onActiveEffect(ActiveEffect, Tile, active_effect_tiles)
	else: ActiveEffect.owner.onActiveEffect(ActiveEffect, Tile, active_effect_tiles, Card)
		
		
	var actions: Array = [
		ChangeActiveEffectChargesAction.new(ActiveEffect, -1),
		ChangeActiveEffectUsedAction.new(ActiveEffect, true)]
	onPushAction(actions)

func getLogInfo() -> Array:
	return ["ActiveEffect: " + ActiveEffect.name]
