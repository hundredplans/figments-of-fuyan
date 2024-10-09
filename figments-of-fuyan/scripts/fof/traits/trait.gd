class_name TraitGD extends FofGD

var Card: CardGD
func onSave() -> SavedData:
	return SavedDataTrait.new(info.id, false, Card.getCoords())
	
func onLoadData(data: SavedData) -> void:
	super(data)
	Card = Game.getFieldCard(Game.getTile(data.coords))
