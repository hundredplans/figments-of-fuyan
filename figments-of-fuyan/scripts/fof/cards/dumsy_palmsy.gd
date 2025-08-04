extends CardGD

const TIER_ONE_HEAL: int = 1
const TIER_TWO_HEAL: int = 1
const TIER_THREE_HEAL: int = 2
const TIER_FOUR_HEAL: int = 2

const TIER_ONE_DAMAGE: int = 2
const TIER_TWO_DAMAGE: int = 3
const TIER_THREE_DAMAGE: int = 3
const TIER_FOUR_DAMAGE: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidArrive(action):
		onPushAction(ArriveAction.new(self, action))
	elif isValidRampage(action):
		onPushAction(RampageAction.new(self, action))

func onArrivePre(_action: AwakenAction) -> void:
	pass

func onArrive(_action: AwakenAction) -> void:
	var damage_action := DamageAction.new(self, self, getTierDamage())
	damage_action.setActionDelay(0.0)
	damage_action.setLockActionDelay(true)
	
	onPushAction(damage_action)

func onRampage(_action: DeathAction) -> void:
	var cards: Array = getVisibleFieldCardsAllies() + [self]
	var heal_amount: int = getTierHeal()
	onPushAction(HealAction.new(cards.map(func(x: CardGD): return HealDatastore.new(x, heal_amount))))
	
func getTierDamage() -> int:
	match tier:
		1: return TIER_ONE_DAMAGE
		2: return TIER_TWO_DAMAGE
		3: return TIER_THREE_DAMAGE
		4: return TIER_FOUR_DAMAGE
	return 0
	
func getTierHeal() -> int:
	match tier:
		1: return TIER_ONE_HEAL
		2: return TIER_TWO_HEAL
		3: return TIER_THREE_HEAL
		4: return TIER_FOUR_HEAL
	return 0
	
