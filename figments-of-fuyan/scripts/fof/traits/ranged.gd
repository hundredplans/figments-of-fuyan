class_name RangedGD extends TraitGD

var ranged: int
func onLoadData(data: SavedData) -> void:
	super(data)
	ranged = data.ranged
	
func onSave() -> SavedDataRanged:
	return SavedDataRanged.new(info.id, false, public_id, Card.getCoords(), ranged)
