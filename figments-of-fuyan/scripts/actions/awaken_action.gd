class_name AwakenAction extends Action

var Card: CardGD
var Tile: TileGD
var tile_rotation: int
var override_spectate: bool

func _init(_Card: CardGD = null, _Tile: TileGD = null, _override_spectate: bool = false) -> void:
	super()
	Card = _Card
	Tile = _Tile
	override_spectate = _override_spectate

func onPreAction() -> void:
	if Game.getFieldCard(Tile) != null: onFailAction(); return
	
	var occupy_actions: Array = Game.ActionManagerReference.getActionsByType(OccupyAction)
	if occupy_actions.any(func(x: OccupyAction): return x.force_occupy and x.Tile == Tile):
		onFailAction()
		return
		
	if Card.isAlly(0):
		Card.add_to_group("AllyCardsGD")

func onPostAction() -> void:
	var SpawnObject: SpawnGD = Tile.getSpawnTile()
	if SpawnObject != null: Card.tile_rotation = SpawnObject.tile_rotation
	
	onPushAction(FinishAwakenAction.new(Card, override_spectate)) # Important it's here so the other pushes move it back
	Card.onChangeCardPlace(Game.CardPlaces.FIELD)
	
	Card.vision_datastore.setInfo() # Loads in all the game objects
	for OtherCard in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
		OtherCard.onAddVisibleGameObject(Card)
	
	onForceAction(OccupyAction.new(Card, Tile))
	
	Card.onAwaken()
	Card.onCreateInitialTraits()
	
	var actions: Array = []
	var phase: Game.Phases = Game.getLevel().getPhase()
	
	if phase != Game.Phases.START:
		var turn_amount: int = 1 if phase != Game.Phases.HAND else 2
		actions.append(Card.getBaseStatusEffectAction(3, turn_amount))
		
	actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.INACTIVE if owner is not PlayCardAction else Game.TurnStates.PASSED, false, true))
	Card.onRegularReset()
	
	onPushAction(actions)
	Audio.onSoundEffect(Card.getInfo().getAwakenAudio())

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
