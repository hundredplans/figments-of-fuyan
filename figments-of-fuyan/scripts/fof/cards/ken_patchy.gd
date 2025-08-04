extends CardGD

var on_hit_charges: int
const TIER_ONE_ON_HIT: int = -1
const TIER_TWO_ON_HIT: int = 2
const TIER_THREE_ON_HIT: int = 1
const TIER_FOUR_ON_HIT: int = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidOnHit(action) and on_hit_charges != 0:
		onPushAction(OnHitAction.new(self, action))

func onHit(_damage_action: DamageAction, _attack_action: AttackAction) -> void:
	if on_hit_charges > 0:
		on_hit_charges -= 1
	onStun(2)
	
func onRetiered(_tier: int) -> void:
	super(_tier)
	on_hit_charges = getDefaultCharges()
	
func getDescription(use_default_values: bool = false) -> String:
	if !use_default_values:
		return Helper.getDescription(super(), [on_hit_charges])
	return super(use_default_values)

func getDefaultCharges() -> int:
	return getTierOnHitCharges()
	
func onRegularReset() -> void:
	super()
	on_hit_charges = getDefaultCharges()
	
func onSave() -> SavedDataCard:
	ability_save['on_hit_charges'] = on_hit_charges
	return super()

func getTierOnHitCharges() -> int:
	match tier:
		1: return TIER_ONE_ON_HIT
		2: return TIER_TWO_ON_HIT
		3: return TIER_THREE_ON_HIT
		4: return TIER_FOUR_ON_HIT
	return 0
