class_name ArmorGD extends TraitGD

var armor: int
func onLoadData(data: SavedData) -> void:
	super(data)
	armor = data.armor
	
func onSave() -> SavedDataArmor:
	return SavedDataArmor.new(info.id, false, public_id, Card.getCoords(), armor)
	
func onProcessAction(action: Action) -> void:
	if !action.post:
		if action is DamageAction and action.Defender == Card and !action.is_fall_damage:
			action.damage = max(action.damage - armor, 0)

func getDescription() -> String:
	return Helper.getDescription(super(), [armor])
