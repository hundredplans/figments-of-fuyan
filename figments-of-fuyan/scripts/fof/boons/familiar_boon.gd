extends BoonGD

const TIER_ONE_ATTACK: int = 0
const TIER_TWO_ATTACK: int = 1
const TIER_THREE_ATTACK: int = 1
const TIER_FOUR_ATTACK: int = 1

const TIER_ONE_MAX_HP: int = 1
const TIER_TWO_MAX_HP: int = 1
const TIER_THREE_MAX_HP: int = 1
const TIER_FOUR_MAX_HP: int = 2

const TIER_ONE_SPEED: int = 0
const TIER_TWO_SPEED: int = 0
const TIER_THREE_SPEED: int = 1
const TIER_FOUR_SPEED: int = 1

var ally_names_played: Array # [String]
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.owner != null and action.owner is PlayCardAction:
			var card_name: String = action.Card.info.name
			if !ally_names_played.is_empty() and ally_names_played.any(func(x: String): return x == card_name):
				onPushAction(BoonActivatedAction.new(self, action))
			ally_names_played.append(card_name)
		elif action is EndGameAction:
			ally_names_played = []
	
func onSave() -> SavedDataBoon:
	ability_save['ally_names_played'] = ally_names_played
	return super()

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: AwakenAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(action.Card,\
		[Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH, Game.Stats.MAX_SPEED],\
		[getTierAttack(), getTierMaxHp(), getTierMaxHp(), getTierSpeed()])))

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

func getTierSpeed() -> int:
	match tier:
		1: return TIER_ONE_SPEED
		2: return TIER_TWO_SPEED
		3: return TIER_THREE_SPEED
		4: return TIER_FOUR_SPEED
	return 0
