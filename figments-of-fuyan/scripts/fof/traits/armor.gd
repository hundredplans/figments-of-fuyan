class_name ArmorGD extends TraitGD

var armor: int
func onLoadData(data: SavedData) -> void:
	super(data)
	armor = data.armor
	
func onSaveData() -> SavedDataArmor:
	return SavedDataArmor.new(info.id, false, armor)
