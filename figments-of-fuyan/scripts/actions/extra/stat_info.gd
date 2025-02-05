class_name StatInfo extends Resource

var Card: CardGD
var owner: FofGD

@export var types: Array
@export var values: Array
@export var turns: int
@export var absolute: bool
@export var show_particles: bool
@export var immutable: bool

@export var card_public_id: int
@export var owner_public_id: int

func _init(_Card: CardGD = null, _types: Variant = null, _values: Variant = null, _turns: int = 0,\
 	_absolute: bool = false, _show_particles: bool = true, _immutable: bool = false) -> void:
	
	Card = _Card
	
	if _types is Array: types = _types
	elif _types is int: types = [_types]
	
	if _values is Array: values = _values
	elif _values is int: values = [_values]
	
	turns = _turns
	absolute = _absolute
	show_particles = _show_particles
	immutable = _immutable
		
func setOwner(_owner: Variant) -> void:
	if owner is FofGD:
		owner = _owner
		
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
		if owner != null: owner.onPushAction(StatAction.new(self), Card)
		else: Card.onPushAction(StatAction.new(self), Card)
		
		Card.onRemoveDelayedStatInfo(self)
