class_name AddTraitAction extends Action

var Trait: TraitGD

func _init(_Trait: TraitGD = null) -> void:
	super()
	Trait = _Trait

func onPostAction() -> void:
	Trait.Card.onAddTrait(Trait)
