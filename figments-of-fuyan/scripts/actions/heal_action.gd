class_name HealAction extends Action

var heal_datastores: Array

func _init(_heal_datastores: Variant) -> void:
	super()
	if heal_datastores != null: # Don't call when reinitialised
		if _heal_datastores is Array: heal_datastores = _heal_datastores
		elif _heal_datastores is HealDatastore: heal_datastores = [_heal_datastores]
	
func onPreAction() -> void:
	heal_datastores = heal_datastores.filter(func(x: HealDatastore): return x.Card.isInjured())
	if heal_datastores.is_empty(): onFailAction()
	
func onPostAction() -> void:
	onPushAction(StatAction.new(heal_datastores.map(func(x: HealDatastore):\
		return StatInfo.new(x.Card, Game.Stats.HEALTH, x.heal, x.turns, false, x.show_particles, x.immutable))))

func hasCard(Card: CardGD) -> bool:
	return heal_datastores.any(func(x: HealDatastore): return x.Card == Card)
