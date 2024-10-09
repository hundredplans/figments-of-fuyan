class_name ArmorGD extends TraitGD

var armor: int
func onLoadData(data: SavedData) -> void:
	super(data)
	armor = data.armor
	
func onSave() -> SavedDataArmor:
	return SavedDataArmor.new(info.id, false, public_id, armor)
