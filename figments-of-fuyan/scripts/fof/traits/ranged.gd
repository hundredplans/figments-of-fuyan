class_name RangedGD extends TraitGD

func onLoadData(data: SavedData) -> void:
	super(data)

func onTraitAdded() -> void:
	onPushAction(ChangeAttackRangeAction.new(Card, getRanged()))

func onClear() -> void:
	super()
	onPushAction(ChangeAttackRangeAction.new(Card, 1))

func getDescription() -> String:
	return Helper.getDescription(super(), [getRanged()])

func getRanged() -> int:
	return display_number
	
func setRanged(ranged: int) -> void:
	display_number = ranged
