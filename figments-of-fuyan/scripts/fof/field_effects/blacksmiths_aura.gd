extends FieldEffectGD

func onLoadData(data: SavedData) -> void:
	super(data)

func getDescription() -> String:
	assert(FofObject != null)
	return Helper.getDescription(super(), [FofObject.ability_turns_remaining, FofObject.getTierArmor()])

func onFieldEffectAdded(_is_init: bool) -> void:
	super(_is_init)
	onForceUpdateDisplayNumber()

func onForceUpdateDisplayNumber() -> void:
	assert(FofObject != null)
	setDisplayNumber(FofObject.ability_turns_remaining)
