extends BoonGD

const PALMY_ID: int = 4
var PalmyCard: CardGD # For UI purposes in childish endeavour
var palmy_public_id: int
func onProcessAction(action: Action) -> void:
	super(action)
	
func onAscend(state: bool) -> void:
	super(state)

func onBoon(_action: Action = null) -> void:
	var card_data: SavedDataCard = Game.onCreateBaseCard(PALMY_ID, true)
	var Card: CardGD = SavedData.onLoadModel(card_data, Game.getSaveFile())
	Card.setIsTemporary(true)
	
	PalmyCard = Card
	
	onPushAction(AddToDeckAction.new(Card))
	setPalmyPublicID(Card.public_id)

func onBoonAdded() -> void:
	super()
	onPushAction(BoonActivatedAction.new(self, null))
	
func onLevelStarted() -> void:
	super()

func getDisabled() -> bool:
	return super()

func onRemoveBoon() -> void:
	super()
	
	var Card: CardGD = Game.onFindPublicIDObject(palmy_public_id)
	if Card != null:
		onPushAction(RemoveFromDeckAction.new(Card, true))
	
func setPalmyPublicID(_public_id: int) -> void:
	palmy_public_id = _public_id
	
func getPalmyCard() -> CardGD:
	return PalmyCard
	
func onSave() -> SavedDataBoon:
	ability_save["palmy_public_id"] = palmy_public_id
	return super()
