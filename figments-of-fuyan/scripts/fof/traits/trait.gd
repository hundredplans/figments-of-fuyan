class_name TraitGD extends FofGD

var Card: CardGD
func onSave() -> SavedData:
	return SavedDataTrait.new(info.id, false, public_id)
	
func onLoadData(data: SavedData) -> void:
	super(data)

func getIcon() -> Texture2D:
	return info.icon

func getDescription() -> String:
	return info.description
