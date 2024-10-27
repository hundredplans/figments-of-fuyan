class_name BoonGD extends FofGD

var ascended: bool
var ability_save: Dictionary

func onLoadData(data: SavedData) -> void:
	add_to_group("BoonsGD")
	ascended = data.ascended
	
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
func onSave() -> SavedDataBoon:
	return SavedDataBoon.new(info.id, false, public_id, ascended, ability_save)

func getIcon() -> ImageTexture:
	return ImageTexture.create_from_image(info.icon)

func getDescription() -> String:
	return info.description if !ascended else info.ascended_description	

func onAscenscionChanged() -> void:
	pass
	
func onBoonAdded() -> void:
	pass
