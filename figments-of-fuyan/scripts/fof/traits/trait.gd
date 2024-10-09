class_name TraitGD extends FofGD

var Card: CardGD
func onSave() -> SavedData:
	return SavedDataTrait.new(info.id, false, public_id, Card.getCoords())
	
func onLoadData(data: SavedData) -> void:
	super(data)
	Card = Game.getFieldCard(Game.getTile(data.coords))

func getIcon() -> Texture2D:
	return info.icon
