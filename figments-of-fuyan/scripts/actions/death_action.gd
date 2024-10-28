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
	
func onPostAction() -> void:
	Defender.onDeath()
	Defender.onChangeCardPlace(Game.CardPlaces.GRAVEYARD)
	onPushAction([OccupyAction.new(Defender, null, true)])
	
func getDelay() -> float:
	return delay
