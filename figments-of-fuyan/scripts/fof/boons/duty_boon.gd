extends BoonGD

const TIER_ONE_ENERGY: int = 0
const TIER_TWO_ENERGY: int = 1
const TIER_THREE_ENERGY: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0) and charges != 0:
			onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: DeathAction) -> void:
	pass
	#var DefenderCard: CardGD = action.Defender
	#var card_info: CardInfo = Helper.getFofInfoID(CardInfo, DefenderCard.info.id)
	#var card_data: SavedDataCard = card_info.saved_data.new(card_info.id, true)
	#Game.setCardDataFromInfo(card_data, card_info)
	#
	#var Card: CardGD = SavedData.onLoadModel(card_data, Game.getArea().active_level)
	#var actions: Array = [ChangeBoonChargesAction.new(self, -1),
		#InsertAction.new(Card), CardEnergyAction.new(Card, -getTierEnergy(Card))]
	#onPushAction(actions)

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super() or charges == 0

func getCharges() -> int:
	return super()
	
func getDefaultCharges() -> int:
	return 1
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierEnergy(Card: CardGD) -> int:
	match tier:
		1: return TIER_ONE_ENERGY
		2: return TIER_TWO_ENERGY
		3: return TIER_THREE_ENERGY
		4: return Card.getEnergy()
	return 0
