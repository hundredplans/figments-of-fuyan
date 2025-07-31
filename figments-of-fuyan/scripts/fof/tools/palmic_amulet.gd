extends ToolGD

const TIER_ONE_HEAL_EFFECTIVENESS: int = 1
const TIER_TWO_HEAL_EFFECTIVENESS: int = 2
const TIER_THREE_HEAL_EFFECTIVENESS: int = 3

const MINIMUM_TIER_FOR_FULL_HEAL: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is HealAction and action.hasCard(Card):
			onForceAction(ToolActivatedAction.new(self, action))
	
func onToolAction(action: HealAction) -> void:
	for heal_datastore: HealDatastore in action.heal_datastores.filter(func(x: HealDatastore): return x.Card == Card):
		if tier < MINIMUM_TIER_FOR_FULL_HEAL:
			heal_datastore.heal += getHealEffectiveness()
		else: heal_datastore.heal += 99
	
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

func getHealEffectiveness() -> int:
	match tier:
		1: return TIER_ONE_HEAL_EFFECTIVENESS
		2: return TIER_TWO_HEAL_EFFECTIVENESS
		3: return TIER_THREE_HEAL_EFFECTIVENESS
		4: return 0
	return 0
