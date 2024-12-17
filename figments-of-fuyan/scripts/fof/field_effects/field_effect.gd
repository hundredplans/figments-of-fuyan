class_name FieldEffectGD extends FofGD

signal update_charges

var Card: CardGD
var FofObject: FofGD # Equivalent to owner
var ability_save: Dictionary
var charges: int = -1

func getDescription() -> String:
	match info.ascended_type:
		FieldEffectInfo.AscendedTypes.CARD:
			if Card.ascended: return info.ascended_description
		FieldEffectInfo.AscendedTypes.OWNER:
			if FofObject.ascended: return info.ascended_description
	return info.description
	
func getIcon() -> Texture2D:
	return info.icon
	
func onSave() -> SavedData:
	return SavedDataFieldEffect.new(info.id, false, public_id, FofObject.public_id, charges, ability_save)

func onLoadData(data: SavedData) -> void:
	super(data)
	ability_save = data.ability_save
	
	if data.fof_object_public_id != 0:
		FofObject = Game.onFindPublicIDObject(data.fof_object_public_id)
		
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
		
	setCharges(data.charges)
		
func onRemoveFromCard() -> void: # Removes field effect from the card
	Card.onRemoveFieldEffect(self)
	
func setCharges(_charges: int) -> void:
	charges = _charges
	update_charges.emit(charges)
	
func onLevelEnded(_win: bool) -> void:
	onClear()
