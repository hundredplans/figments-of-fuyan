extends FieldEffectGD

func onLoadData(data: SavedData) -> void:
	super(data)

func getDescription() -> String:
	return Helper.getDescription(super(), [FofObject.ability_turns_remaining, FofObject.getTierTurns()])

func onFieldEffectAdded(_is_init: bool) -> void:
	super(_is_init)
	onForceUpdateDisplayNumber()

func onForceUpdateDisplayNumber() -> void:
	setDisplayNumber(FofObject.ability_turns_remaining)
