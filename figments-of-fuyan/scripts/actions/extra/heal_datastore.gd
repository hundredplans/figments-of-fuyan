class_name HealDatastore extends Resource

var Card: CardGD
var owner: FofGD

@export var heal: int
@export var turns: int

@export var show_particles: bool
@export var immutable: bool

@export var card_public_id: int
@export var owner_public_id: int

func _init(_Card: CardGD = null, _heal: int = 0, _turns: int = 0, _show_particles: bool = true, _immutable: bool = false) -> void:
	Card = _Card
	heal = _heal
	turns = _turns
	show_particles = _show_particles
	immutable = _immutable
	
func onSave() -> void:
	card_public_id = Card.public_id
	
	if owner != null:
		owner_public_id = owner.public_id
	
func onLoad() -> void:
	Card = Game.onFindPublicIDObject(card_public_id)
	owner = Game.onFindPublicIDObject(owner_public_id)
	
func onCardTurnPassed() -> void:
	turns -= 1
	if turns == 0:
		if owner != null: owner.onPushAction(HealAction.new(self))
		else: Card.onPushAction(HealAction.new(self))
		
		Card.onRemoveDelayedHealDatastore(self)
		
func getType(_i: int = 0) -> Game.Stats:
	return Game.Stats.HEALTH
	
func getValue(_i: int = 0) -> int:
	return heal
	
func getSize() -> int:
	return 1
