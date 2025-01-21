class_name TraitGD extends FofGD

signal update_charges

var Card: CardGD
func onSave() -> SavedData:
	return SavedDataTrait.new(info.id, false, public_id)
	
func onLoadData(data: SavedData) -> void:
	super(data)

func getIcon() -> Texture2D:
	return info.icon

func getDescription() -> String:
	return info.description

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is AddTraitAction and action.overworld_trait.Trait == self:
			onTraitAdded()
			
func onTraitAdded() -> void:
	pass

func onLevelEnded(_win: bool) -> void:
	onClear()

func getCharges() -> int:
	return -1

func setCharges(_charges: int) -> void:
	update_charges.emit(getCharges())
