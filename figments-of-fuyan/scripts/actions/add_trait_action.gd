class_name AddTraitAction extends Action

var Trait: TraitGD

func _init(_Trait: TraitGD = null, Card: CardGD = null) -> void:
	super()
	Trait = _Trait
	Trait.Card = Card

func onPostAction() -> void:
	Trait.Card.onAddTrait(Trait)
