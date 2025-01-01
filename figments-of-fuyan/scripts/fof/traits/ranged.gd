class_name RangedGD extends TraitGD

var ranged: int
func onLoadData(data: SavedData) -> void:
	super(data)
	ranged = data.ranged
	
func onSave() -> SavedDataRanged:
	return SavedDataRanged.new(info.id, false, public_id, ranged)

func onTraitAdded() -> void:
	onPushAction(ChangeAttackRangeAction.new(Card, ranged))

func onClear() -> void:
	super()
	onPushAction(ChangeAttackRangeAction.new(Card, 1))

func getDescription() -> String:
	return Helper.getDescription(super(), [ranged])

func getCharges() -> int:
	return ranged
	
func setCharges(charges: int) -> void:
	ranged = charges
	super(charges)
