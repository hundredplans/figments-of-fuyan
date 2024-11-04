class_name DeathAction extends Action

var Damager: GameObjectGD
var Defender: GameObjectGD
var damage: int
var health_damage: int
var delay: float

var Tile: TileGD # Where the Defender died
var game_objects_in_vision: Array # When the defender died saved

func _init(_Damager: GameObjectGD = null, _Defender: GameObjectGD = null, _damage: int = 0, _health_damage: int = 0) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage
	health_damage = _health_damage
	
func onPreAction() -> void:
	Tile = Defender.Tile
	game_objects_in_vision = Defender.getVisibleGameObjects()
	delay = 3.0 if Defender.level_visible else 0.0
	Defender.onChangeCardPlace(Game.CardPlaces.GRAVEYARD)
	force_action.emit(OccupyAction.new(Defender, null, true))
	
func onPostAction() -> void:
	Defender.onDeath()
	onSwapCameraOnDeathInPlayerPhase()

func getDelay() -> float:
	return delay
	
func onSwapCameraOnDeathInPlayerPhase() -> void:
	if !Defender.isAlly(0) or Game.get_tree().get_nodes_in_group("LevelsGD")[0].phase != Game.Phases.PLAYER: return
		
	var allies_by_distance: Array = game_objects_in_vision.filter(func(x: GameObjectGD): return x is CardGD and x.isAlly(0) and x != Defender)
	allies_by_distance.sort_custom(func(x: CardGD, y: CardGD):\
		return Game.getCoordsDistance(x.getCoords(), Tile.getCoords()) < Game.getCoordsDistance(y.getCoords(), Tile.getCoords()))
		
	var ally_units: Array = Game.getAllyUnits(0)
	var closest_ally: CardGD = allies_by_distance[0] if !allies_by_distance.is_empty() else (ally_units[0] if !ally_units.is_empty() else null)
	
	if closest_ally == null: return
	
	onPushAction(CameraChangeAction.new(closest_ally))
