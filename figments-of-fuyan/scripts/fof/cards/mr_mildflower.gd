extends CardGD

const DEBUFF_TURNS: int = 2
const TIER_ONE_DEBUFF: int = 1
const TIER_TWO_DEBUFF: int = 2
const TIER_THREE_DEBUFF: int = 3
const TIER_FOUR_DEBUFF: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidLastWill(action):
		onPushAction(LastWillAction.new(self, action))

func onLastWill(death_action: DeathAction) -> void:
	var attack_debuff: int = getTierDebuff() * -1
	var field_cards: Array = death_action.game_objects_in_vision.filter(func(x: GameObjectGD): return x is CardGD)
	var stat_infos: Array = field_cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, attack_debuff, DEBUFF_TURNS))
	onPushAction(StatAction.new(stat_infos))

func getTierDebuff() -> int:
	match tier:
		1: return TIER_ONE_DEBUFF
		2: return TIER_TWO_DEBUFF
		3: return TIER_THREE_DEBUFF
		4: return TIER_FOUR_DEBUFF
	return 0
