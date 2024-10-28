class_name FieldEffectGD extends FofGD

var FofObject: FofGD
var ability_save: Dictionary

func getDescription() -> String:
	return info.description
	
func getIcon() -> Texture2D:
	return info.icon
	
func onSave() -> SavedData:
	return SavedDataFieldEffect.new(info.id, false, 0, FofObject.public_id, ability_save)

func onLoadData(data: SavedData) -> void:
	super(data)
	ability_save = data.ability_save
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
