class_name AddOverworldTraitAction extends Action

var overworld_trait: OverworldTrait
var Card: CardGD
var auto_add: bool

func _init(_Card: CardGD = null, _overworld_trait: OverworldTrait = null, _auto_add: bool = false) -> void:
	super()
	Card = _Card
	overworld_trait = _overworld_trait
	auto_add = _auto_add
	
func onPreAction() -> void:
	var current_overworld_trait: OverworldTrait = Card.getOverworldTraitByID(overworld_trait.getData().id)
	if current_overworld_trait != null:
		if current_overworld_trait.isUnregularAdded(): # If already exists and is an Other
			onForceAction(RemoveOverworldTraitAction.new(Card, current_overworld_trait.getData().id))
		else: onFailAction()
	
func onPostAction() -> void:
	Card.onAddOverworldTrait(overworld_trait)
	if auto_add:
		onPushAction(AddTraitAction.new(Card, overworld_trait))

func getDelay() -> float:
	return super()
