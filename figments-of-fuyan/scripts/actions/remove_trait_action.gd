class_name RemoveTraitAction extends Action

var Trait: TraitGD
func _init(_Trait: TraitGD = null) -> void:
	super()
	Trait = _Trait
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Trait.Card.onRemoveTrait(Trait)
	Trait.onClear()

func getDelay() -> float:
	return super()
