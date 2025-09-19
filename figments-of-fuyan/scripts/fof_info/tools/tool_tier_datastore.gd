class_name ToolTierDatastore extends TierDatastore

@export var description_index_for_active_effect_charges: int = -2 # -2 means invalid, -1 means infinite
func getActiveEffectCharges() -> int:
	if description_index_for_active_effect_charges == -2: return -2
	elif description_index_for_active_effect_charges == -1: return -1
	return description_datastore.getDefaultValue(description_index_for_active_effect_charges)
