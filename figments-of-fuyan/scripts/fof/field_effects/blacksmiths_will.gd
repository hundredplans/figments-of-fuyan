extends FieldEffectGD

func onLoadData(data: SavedData) -> void:
	super(data)
	
	if FofObject == null: return
	onForceUpdateDisplayNumber()

func getDescription() -> String:
	return Helper.getDescription(super(), [FofObject.ability_turns_remaining])

func onFieldEffectAdded() -> void:
	super()
	onForceUpdateDisplayNumber()

func onForceUpdateDisplayNumber() -> void:
	setDisplayNumber(FofObject.ability_turns_remaining)
