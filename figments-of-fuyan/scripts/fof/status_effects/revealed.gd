class_name RevealedGD extends StatusEffectGD

var revealed_id: int

func onProcessAction(action: Action) -> void:
	super(action)

func onStatusEffectAdded(action: AddStatusEffectAction) -> void:
	var revealed_datastore := Game.onCreateRevealedDatastore(action.owner)
	revealed_id = revealed_datastore.revealed_id
	onPushAction(RevealAction.new(Card, revealed_datastore))

func onClear() -> void:
	super()
	onPushAction(RemoveRevealAction.new(Card, revealed_id))

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])

func onSave() -> SavedData:
	ability_save['revealed_id'] = revealed_id
	return super()
