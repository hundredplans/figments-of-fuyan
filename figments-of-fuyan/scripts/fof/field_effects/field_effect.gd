class_name FieldEffectGD extends FofGD

var FofObject: FofGD
func getDescription() -> String:
	return info.description
	
func getIcon() -> Texture2D:
	return info.icon
	
func onSave() -> SavedData:
	return SavedDataFieldEffect.new(info.id, false, 0, FofObject.public_id)
