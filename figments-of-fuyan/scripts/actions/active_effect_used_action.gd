class_name ActiveEffectUsedAction extends Action

var ActiveEffect: ActiveEffectDatastore
var Tile: TileGD
var active_effect_tiles: ActiveEffectTiles
var Card: CardGD # Card that triggered the active effect

func _init(_ActiveEffect: ActiveEffectDatastore = null, _Tile: TileGD = null, _active_effect_tiles: ActiveEffectTiles = null, _Card: CardGD = null) -> void:
	super()
	ActiveEffect = _ActiveEffect
	Tile = _Tile
	active_effect_tiles = _active_effect_tiles
	Card = _Card
	
func onPreAction() -> void:
	if ActiveEffect.owner is not IObjectGD: ActiveEffect.owner.onActiveEffectPre(ActiveEffect, Tile, active_effect_tiles)
	else: ActiveEffect.owner.onActiveEffectPre(ActiveEffect, Tile, active_effect_tiles, Card)
	setActionDelay(ActiveEffect.delay if ActiveEffect.owner.isLevelVisible() else 0.0)
	
func onPostAction() -> void:
	var actions: Array = [
		ChangeActiveEffectChargesAction.new(ActiveEffect, -1),
		ChangeActiveEffectUsedAction.new(ActiveEffect, true)]
	
	if ActiveEffect.owner is not IObjectGD:
		ActiveEffect.owner.onActiveEffect(ActiveEffect, Tile, active_effect_tiles)
		
		if ActiveEffect.owner is CardGD: actions.append(CameraChangeAction.new(ActiveEffect.owner))
		elif ActiveEffect.owner is ToolGD: actions.append(CameraChangeAction.new(ActiveEffect.owner.Card))
		
	else: ActiveEffect.owner.onActiveEffect(ActiveEffect, Tile, active_effect_tiles, Card)
		
	if Card.turn_state == Game.TurnStates.INACTIVE:
		actions.push_front(ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE))
	
	var ally_cards: Array = Game.getAllyUnits(Card.team)
	for ally_card in ally_cards.filter(func(x: CardGD): return x.turn_state == Game.TurnStates.ACTIVE and x != Card):
		actions.push_front(ChangeTurnStateAction.new(ally_card, Game.TurnStates.PASSED))
	
	onPushAction(actions)

func getLogInfo() -> Array:
	return ["ActiveEffect: " + ActiveEffect.name]
