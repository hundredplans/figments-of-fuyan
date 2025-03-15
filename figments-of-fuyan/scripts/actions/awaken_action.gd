class_name AwakenAction extends Action

var Card: CardGD
var Tile: TileGD
var tile_rotation: int

func _init(_Card: CardGD = null, _Tile: TileGD = null) -> void:
	super()
	Card = _Card
	Tile = _Tile

func onPreAction() -> void:
	pass

func onPostAction() -> void:
	var SpawnObject: SpawnGD = Tile.getSpawnTile()
	if SpawnObject != null: Card.tile_rotation = SpawnObject.tile_rotation
	
	onPushAction(FinishAwakenAction.new(Card)) # Important it's here so the other pushes move it back
	Card.onChangeCardPlace(Game.CardPlaces.FIELD)
	
	Card.vision_datastore.setInfo() # Loads in all the game objects
	for OtherCard in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
		OtherCard.onAddVisibleGameObject(Card)
	
	onForceAction(OccupyAction.new(Card, Tile))
	
	Card.onAwaken()
	Card.onCreateInitialTraits()
	Card.onCreateInitialActiveAbilities()
	
	var actions: Array = []
	var phase: Game.Phases = Game.getLevel().getPhase()
	
	if phase != Game.Phases.START:
		var turn_amount: int = 1 if phase != Game.Phases.HAND else 2
		actions.append(Card.getBaseStatusEffectAction(3, turn_amount))
		
	actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.INACTIVE if owner is not PlayCardAction else Game.TurnStates.PASSED))
	Card.onRegularReset()
	
	onPushAction(actions)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
