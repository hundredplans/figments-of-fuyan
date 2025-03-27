class_name HealAction extends Action

var heal_datastores: Array
func _init(_heal_datastores: Variant) -> void:
	super()
<<<<<<< HEAD
	if heal_datastores != null: # Don't call when reinitialised
		if _heal_datastores is Array: heal_datastores = _heal_datastores
		elif _heal_datastores is HealDatastore: heal_datastores = [_heal_datastores]
=======
	if _cards is CardGD: cards = [_cards]
	else: cards = _cards
	
	if _heals is int: heals = [_heals]
	else:
		heals = _heals
	if heals.size() < cards.size():
		heals.resize(cards.size())
		
		for i in range(heals.size()):
			if heals[i] == null: heals[i] = heals[0]
>>>>>>> 4f1fb7da3a0d6845469734427bd6f420ecdb61bd
	
func onPreAction() -> void:
	if heal_datastores.is_empty() or heal_datastores\
		.all(func(x: HealDatastore): return !x.Card.isInjured()):
		return onFailAction()
	
func onPostAction() -> void:
	onPushAction(StatAction.new(heal_datastores.map(func(x: HealDatastore):\
		return StatInfo.new(x.Card, Game.Stats.HEALTH, x.heal, x.turns, false, x.show_particles, x.immutable))))
