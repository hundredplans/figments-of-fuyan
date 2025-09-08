class_name ToolTierDatastore extends TierDatastore

@export var active_abilities: Array[ActiveEffectDatastore]
func getActiveAbilities() -> Array:
	return active_abilities.map(func(x: ActiveEffectDatastore): return x.duplicate())
