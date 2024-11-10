class_name AITurnAction extends Action

var Card: CardGD
var ignore_attack_chance: bool

func _init(_Card: CardGD, _ignore_attack_change: bool = false) -> void:
	super()
	Card = _Card
	ignore_attack_chance = _ignore_attack_change
		
func onPostAction() -> void:
	var tiles: Array = Game.getsetMovementRange(Card)
	tiles.erase(Card.Tile)
	var attackables: Array = tiles.filter(func(x: TileGD): return Game.getFieldCard(x))
	
	for AttackableTile in attackables:
		tiles.erase(AttackableTile)
	
	var attackable: TileGD
	if !attackables.is_empty() and !ignore_attack_chance:
		attackable = attackables.pick_random()
	
	var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE), MovementAction.new(Card, attackable if attackable != null else tiles.pick_random())]
	onPushAction(actions)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
