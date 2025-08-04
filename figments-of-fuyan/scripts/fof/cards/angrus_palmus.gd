extends CardGD

const ABILITY_DELAY: float = 2.4

var rampage_charges: int
const TIER_ONE_CHARGES: int = 3
const TIER_TWO_CHARGES: int = -1
const TIER_THREE_CHARGES: int = -1
const TIER_FOUR_CHARGES: int = -1

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and rampage_charges != 0:
		onPushAction(RampageAction.new(self, action))
	
func onRampage(death_action: DeathAction) -> void:
	onAbility()
	
	var enemies: Array = Game.getAdjacentTiles(death_action.Tile).map(func(x: TileGD): return Game.getFieldCard(x))\
		.filter(func(x: CardGD): return x != null and isEnemy(x.team))
	
	if !enemies.is_empty():
		var actions: Array = []
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
	
		actions.append(DamageAction.new(self, enemies, attack, Game.DamageTypes.OTHER))
		onPushAction(actions)
		if rampage_charges > 0:
			rampage_charges -= 1

func onResetCharges() -> void:
	rampage_charges = getTierCharges()

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [rampage_charges])

func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	return super()
	
func onAwaken() -> void:
	super()
	onResetCharges()

func onFofInit() -> void:
	super()
	onResetCharges()

func onRegularReset() -> void:
	super()
	onResetCharges()
	
func onRetiered(tier: int) -> void:
	super(tier)
	onResetCharges()
	
func getTierCharges() -> int:
	match tier:
		1: return TIER_ONE_CHARGES
		2: return TIER_TWO_CHARGES
		3: return TIER_THREE_CHARGES
		4: return TIER_FOUR_CHARGES
	return 0
