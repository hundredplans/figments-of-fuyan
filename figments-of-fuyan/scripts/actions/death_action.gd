class_name DeathAction extends Action

var Damager: GameObjectGD
var Defender: GameObjectGD
var damage: int
var health_damage: int

var Tile: TileGD # Where the Defender died
var game_objects_in_vision: Array # When the defender died saved
var card_to_visible_defender: Dictionary # CardGD: bool, if the card saw this unit before death

func _init(_Damager: GameObjectGD = null, _Defender: GameObjectGD = null, _damage: int = 0, _health_damage: int = 0) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage
	health_damage = _health_damage
	
func onPreAction() -> void:
	if !Defender.isAlive(): onFailAction(); return
	
	Tile = Defender.Tile
	game_objects_in_vision = Defender.getVisibleGameObjects()
	
	for Card in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
		card_to_visible_defender[Card] = Defender in Card.getVisibleFieldCards()
	
	setActionDelay(3.0 if Defender.isLevelVisible() else 0.0)
	Defender.onChangeCardPlace(Game.CardPlaces.GRAVEYARD)
	Defender.onPreDeath()
	
	onForceAction(OccupyAction.new(Defender, null, true))
	
func onPostAction() -> void:
	Defender.onDeath()
	onSwapCameraOnDeathInPlayerPhase()
	
	if !Game.getLevel().isEpic() and Defender is CardGD and Defender.isEnemy(0) and\
	!(Defender.is_awakened_in_combat or Defender.info.rarity in [Game.Rarities.SCRAP, Game.Rarities.NEUTRAL]):
		onPushAction(EnergyAction.new(Defender.energy))
	
	for Card in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
		Card.onRemoveVisibleGameObject(Defender)
	
	if onCheckEndGame():
		onAppendAction(EndGameAction.new(Defender.team, Game.getLevel().isEpic()))
			
	Defender.onRegularReset()
			
func onSwapCameraOnDeathInPlayerPhase() -> void:
	if Game.getLevel().phase != Game.Phases.PLAYER: return
	
	var action: Action
	if Defender.isAlly(0):
		var allies_by_distance: Array = Game.getAllyUnits(0).filter(func(x: GameObjectGD): return x is CardGD and x.isAlly(0) and x != Defender)
		allies_by_distance.sort_custom(func(x: CardGD, y: CardGD):\
			return Game.getCoordsDistance(x.getCoords(), Tile.getCoords()) < Game.getCoordsDistance(y.getCoords(), Tile.getCoords()))
			
		var ally_units: Array = Game.getAllyUnits(0)
		var closest_ally: CardGD = allies_by_distance[0] if !allies_by_distance.is_empty() else (ally_units[0] if !ally_units.is_empty() else null)
		
		if closest_ally == null: return
		action = CameraChangeAction.new(closest_ally)
	else: action = CameraSpectateGroupAction.new(0)
	onPushAction(action)
	
func getCardSawDefenderDie(Card: CardGD) -> bool:
	return card_to_visible_defender[Card]
	
func getGameObjectsInVision() -> Array:
	return game_objects_in_vision

func onCheckEndGame() -> bool:
	if Game.getLevel().isEpic() and Game.getLevel().getBoss() == Defender:
		return true
		
	return Defender.team != 2 and Game.get_tree().get_nodes_in_group("FieldCardsGD")\
		.filter(func(x: CardGD): return x.team == Defender.team).is_empty()
