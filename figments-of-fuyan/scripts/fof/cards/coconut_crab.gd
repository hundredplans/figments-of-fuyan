extends CardGD

const ARRIVE_ANIMATION_DELAY: float = 2
var stepped_on_card_public_id: int
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if isValidArrive(action) and action.owner is IObjectGD and action.owner.info.name == "Lottery Coconut":
			stepped_on_card_public_id = action.owner.stepped_on_card_public_id
			var arrive_action := ArriveAction.new(self, action)
			arrive_action.setActionDelayWithOverride(ARRIVE_ANIMATION_DELAY)
			onAppendAction(arrive_action)
	
func getDescription() -> String:
	return super()

func onArrivePre(_action: AwakenAction) -> void:
	onAbility()

func onArrive(action: AwakenAction) -> void:
	assert(stepped_on_card_public_id > 0)
	var SteppedOnCard: CardGD = Game.onFindPublicIDObject(stepped_on_card_public_id)
	var actions: Array = [
		DamageAction.new(self, SteppedOnCard, 1),
		ChangeTileRotationAction.new(SteppedOnCard, Game.getRelativeTileRotation(SteppedOnCard.Tile, Tile)),
		AITurnAction.new(self, true),
		]
	onPushAction(actions)

func onSave() -> SavedDataCard:
	ability_save['stepped_on_card_public_id'] = stepped_on_card_public_id
	return super()
