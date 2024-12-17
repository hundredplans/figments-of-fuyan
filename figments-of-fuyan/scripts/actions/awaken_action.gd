class_name AwakenAction extends Action

var Card: CardGD
var Tile: TileGD
var tile_rotation: int

func _init(_Card: CardGD = null, _Tile: TileGD = null) -> void:
	super()
	Card = _Card
	Tile = _Tile

func onPreAction() -> void:
	onForceAction(OccupyAction.new(Card, Tile))

func onPostAction() -> void:
	var SpawnObject: SpawnGD = Tile.getSpawnTile()
	if SpawnObject != null: Card.tile_rotation = SpawnObject.tile_rotation
	
	onPushAction(FinishAwakenAction.new(Card)) # Important it's here so the other pushes move it back
	Card.onChangeCardPlace(Game.CardPlaces.FIELD)
	Card.onAwaken()
	Card.onCreateInitialTraits()
	Card.onCreateInitialActiveAbilities()
	
	var actions: Array = []
	if owner is PlayCardAction:
		if Card.info.rarity != Game.Rarities.CHAMPION:
			actions.append(Card.getBaseStatusEffectAction(3, 2))
	else: actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.INACTIVE))
		
	if Card.Tool != null: actions.append(AddToolAction.new(Card, Card.Tool))
		
	onPushAction(actions)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
