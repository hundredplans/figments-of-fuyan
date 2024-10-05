class_name DeathAction extends Action

var Damager: GameObjectGD
var Defender: GameObjectGD
var damage: int
var health_damage: int

func _init(_Damager: GameObjectGD = null, _Defender: GameObjectGD = null, _damage: int = 0, _health_damage: int = 0) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage
	health_damage = _health_damage
	
func onPreAction() -> void:
	force_action.emit(OccupyAction.new(Defender, null, true))
	
func onPostAction() -> void:
	Defender.onDeath()
	Defender.onChangeCardPlace(Game.CardPlaces.GRAVEYARD)
	
func getDelay() -> float:
	return 3.0
