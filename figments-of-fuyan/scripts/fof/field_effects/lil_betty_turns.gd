extends FieldEffectGD

func onLoadData(data: SavedData) -> void:
	super(data)
	if FofObject == null: return # Intended behaviour on first load
	onForceUpdateDisplayNumber()

func getDescription() -> String:
	assert(FofObject != null)
	return Helper.getDescription(super(), [FofObject.turns_remaining])

func onFieldEffectAdded() -> void:
	super()
	onForceUpdateDisplayNumber()

func onForceUpdateDisplayNumber() -> void:
	assert(FofObject != null)
	setDisplayNumber(FofObject.turns_remaining)
