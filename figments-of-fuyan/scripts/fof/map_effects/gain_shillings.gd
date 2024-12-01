extends MapEffectGD

var shillings: int

#region Save / Load
func onSave() -> SavedData:
	return SavedDataGainShillings.new(info.id, false, public_id, shillings)

func onLoadData(data: SavedData) -> void:
	super(data)
	shillings = data.shillings
#endregion

#region Getters
func getDescription() -> String:
	return Helper.getDescription(info.description, [shillings])
	
func getIcon() -> Texture2D:
	return load(info.SHILLING_ICON_PATH)
#endregion

#region Pickup
func onPickup(save_file: SaveFileGD) -> void:
	save_file.onUpdateShillings(shillings)
#endregion
