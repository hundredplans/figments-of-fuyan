class_name MapEffectGD extends FofGD

#region Save / Load
func onSave() -> SavedData:
	return SavedDataMapEffect.new(info.id, false, public_id)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("MapEffectsGD")
#endregion

#region Description
func getDescription() -> String:
	return info.description
#endregion

#region Pickup
func onPickup(_save_file: SaveFileGD) -> void: pass
#endregion
