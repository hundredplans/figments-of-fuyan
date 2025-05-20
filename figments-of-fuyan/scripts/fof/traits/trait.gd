class_name TraitGD extends FofGD

signal update_display_number

var Card: CardGD
var display_number: int

func onSave() -> SavedData:
	return SavedDataTrait.new(info.id, false, public_id, display_number)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	display_number = data.display_number

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
	
func setDisplayNumber(_display_number: int) -> void:
	display_number = _display_number
	update_display_number.emit(display_number)

func getDisplayNumber() -> int:
	return display_number
