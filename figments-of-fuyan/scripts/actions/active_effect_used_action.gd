class_name ActiveEffectUsedAction extends Action

var item: FofGD
var Tile: TileGD
var active_effect_tiles: ActiveEffectTiles
var Card: CardGD

func _init(_item: FofGD = null, _Tile: TileGD = null, _active_effect_tiles: ActiveEffectTiles = null, _Card: CardGD = null) -> void:
	super()
	item = _item
	Tile = _Tile
	active_effect_tiles = _active_effect_tiles
	Card = _Card
	
func onPreAction() -> void:
	if item is not IObjectGD: item.onActiveEffectPre(Tile, active_effect_tiles)
	else: item.onActiveEffectPre(Tile, active_effect_tiles, Card)
	
func onPostAction() -> void:
	var actions: Array = [
		ChangeActiveEffectChargesAction.new(item, -1),
		ChangeActiveEffectUsedAction.new(item, true)]
	
	if item is not IObjectGD:
		item.onActiveEffect(Tile, active_effect_tiles)
		
		if item is CardGD:
			Card = item
			actions.append(CameraChangeAction.new(item))
		elif item is ToolGD:
			Card = item.Card
			actions.append(CameraChangeAction.new(Card))
	else: item.onActiveEffect(Tile, active_effect_tiles, Card)
		
	if Card != null and Card.turn_state == Game.TurnStates.INACTIVE:
		actions.push_front(ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE))
	
	var ally_cards: Array = Game.getAllyUnits(Card.team)
	for ally_card in ally_cards.filter(func(x: CardGD): return x.turn_state == Game.TurnStates.ACTIVE and x != Card):
		actions.push_front(ChangeTurnStateAction.new(ally_card, Game.TurnStates.PASSED))
	
	onPushAction(actions)
