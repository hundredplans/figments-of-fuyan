extends CardGD

const ARRIVE_ANIMATION_DELAY: float = 2
const COCONUT_ID: int = 13
var stepped_on_card_public_id: int

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if isValidArrive(action) and action.owner is IObjectGD and action.owner.info.name == "Lottery Coconut":
			stepped_on_card_public_id = action.owner.stepped_on_card_public_id
			var arrive_action := ArriveAction.new(self, action)
			arrive_action.setActionDelay(ARRIVE_ANIMATION_DELAY)
			arrive_action.setLockActionDelay(true)
			onAppendAction(arrive_action)
		elif isValidLastWill(action):
			onPushAction(LastWillAction.new(self, action))
	#elif !action.post:
		#if action is FinishAwakenAction and action.Card == self:
			#action.setActionDelay(0.0)
			#action.setLockActionDelay(true)
	
func getDescription() -> String:
	return super()

func onArrivePre(_action: AwakenAction) -> void:
	onAbility()
	
	var SteppedOnCard: CardGD = Game.onFindPublicIDObject(stepped_on_card_public_id)
	onForceAction(ChangeTileRotationAction.new(SteppedOnCard, Game.getRelativeTileRotation(SteppedOnCard.Tile, Tile)))
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, SteppedOnCard.Tile)))

func onArrive(_action: AwakenAction) -> void:
	assert(stepped_on_card_public_id > 0)
	var SteppedOnCard: CardGD = Game.onFindPublicIDObject(stepped_on_card_public_id)
	var actions: Array = [
		DamageAction.new(self, SteppedOnCard, 1),
		AITurnAction.new(self, true, true),
		]
	onPushAction(actions)
	
func onLastWill(action: DeathAction) -> void:
	onPushAction(CreateObjectAction.new(COCONUT_ID, action.Tile))

func onSave() -> SavedDataCard:
	ability_save['stepped_on_card_public_id'] = stepped_on_card_public_id
	return super()
