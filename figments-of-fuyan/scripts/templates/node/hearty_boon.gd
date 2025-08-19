extends BoonGD

const TIER_ONE_ATTACK: int = 0
const TIER_TWO_ATTACK: int = 1
const TIER_THREE_ATTACK: int = 1
const TIER_FOUR_ATTACK: int = 2

const TIER_ONE_MAX_HP: int = 1
const TIER_TWO_MAX_HP: int = 1
const TIER_THREE_MAX_HP: int = 2
const TIER_FOUR_MAX_HP: int = 2

var cards_played: int = 0
const CARDS_PLAYED_MAX_AMOUNT: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.owner != null and action.owner is PlayCardAction\
		and cards_played < CARDS_PLAYED_MAX_AMOUNT and action.Card.info.rarity != Game.Rarities.CHAMPION:
			cards_played += 1
			if cards_played == CARDS_PLAYED_MAX_AMOUNT:
				onPushAction(BoonActivatedAction.new(self, action))
		elif action is EndGameAction:
			cards_played = 0
			onPushAction(BoonDisabledAction.new(self, false))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: AwakenAction) -> void:
	var actions: Array = [StatAction.new(StatInfo.new(action.Card,\
		[Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH],\
		[getTierAttack(), getTierMaxHp(), getTierMaxHp()])),
		BoonDisabledAction.new(self, true)]
	onPushAction(actions)

func onSave() -> SavedDataBoon:
	ability_save['cards_played'] = cards_played
	return super()

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierAttack() -> int:
	match tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
	
func getTierMaxHp() -> int:
	match tier:
		1: return TIER_ONE_MAX_HP
		2: return TIER_TWO_MAX_HP
		3: return TIER_THREE_MAX_HP
		4: return TIER_FOUR_MAX_HP
	return 0
