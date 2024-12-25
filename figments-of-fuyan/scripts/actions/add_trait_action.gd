class_name AddTraitAction extends Action # Should be always called via Card.onAddOverworldTrait

var Card: CardGD
var overworld_trait: OverworldTrait

func _init(_Card: CardGD = null, _overworld_trait: OverworldTrait = null) -> void:
	super()
	Card = _Card
	overworld_trait = _overworld_trait

func onPreAction() -> void:
	onCheckFail()

func onPostAction() -> void:
	Card.onAddFieldTrait(overworld_trait)

func getLogInfo() -> Array:
	return ["Trait ID: " + str(overworld_trait.getData().id), "Card: " + Card.info.name, "AddedBy: " + overworld_trait.getAddedByString()]

func onCheckFail() -> void:
	var id: int = overworld_trait.getData().id
	if Card.getFieldTraits().any(func(x: TraitGD): return x.id == id):
		onFailAction()
