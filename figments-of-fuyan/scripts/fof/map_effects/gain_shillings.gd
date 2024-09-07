extends MapEffectGD

var shillings: int

#region Save / Load
func onSave() -> SavedData:
	return SavedDataMapEffectGainShillings.new(info.id, shillings)

func onLoadData(data: SavedData) -> void:
	super(data)
	shillings = data.shillings
#endregion

#region Getters
func getDescription() -> String:
	return Helper.getDescription(info.description, [shillings])
#endregion

#region Pickup
func onPickup(save_file: SaveFileGD) -> void:
	save_file.onUpdateShillings(shillings)
	queue_free()
#endregion
