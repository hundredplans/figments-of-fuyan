class_name DelayedHealAction extends Action

var heal_datastores: Array
func _init(_heal_datastores: Variant) -> void:
	super()
	if heal_datastores != null: # Don't call when reinitialised
		if _heal_datastores is Array: heal_datastores = _heal_datastores
		elif _heal_datastores is HealDatastore: heal_datastores = [_heal_datastores]
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	for heal_datastore: HealDatastore in heal_datastores.filter(func(x: HealDatastore): return x.turns > 0):
		heal_datastore.owner = owner
		heal_datastore.Card.onAddDelayedHealDatastore(heal_datastore)
