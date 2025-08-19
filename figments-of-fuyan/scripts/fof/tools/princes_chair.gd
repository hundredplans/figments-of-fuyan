extends ToolGD

const TIER_ONE_SPEED: int = 1
const TIER_TWO_SPEED: int = 1
const TIER_THREE_SPEED: int = 1
const TIER_FOUR_SPEED: int = 2

const MINIMUM_TIER_TRAUMA: int = 3

func onProcessAction(action: Action) -> void:
	super(action)
	if Card != null and (Card.isValidBloodthirst(action)\
		or (tier >= MINIMUM_TIER_TRAUMA and Card.isValidTrauma(action))):
		onPushAction(ToolActivatedAction.new(self, action))
	
func onToolAction(action: Action) -> void:
	if action is not AwakenAction:
		onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, 1)))
	else:
		pass
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()

func onToolHolderAwakened() -> void: # Unit awakens
	super()
	
func onToolHolderDeath() -> void: # Unit dies
	super()
	
func onCardTurnPassed() -> void:
	super()
	
func onReset(override: bool = false) -> void: # Level ends
	super(override)

func getTierSpeed() -> int:
	match tier:
		1: return TIER_ONE_SPEED
		2: return TIER_TWO_SPEED
		3: return TIER_THREE_SPEED
		4: return TIER_FOUR_SPEED
	return 0
