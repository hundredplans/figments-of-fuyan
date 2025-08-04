extends CardGD
	
var rampage_charges: int = 1
const RAMPAGE_DELAY: float = 2.0

const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 1
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 2

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [rampage_charges])

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and rampage_charges > 0:
		onPushAction(RampageAction.new(self, action))
	
func onRampage(_death_action: DeathAction) -> void:
	var attack_value: int = getTierAttack()
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(RAMPAGE_DELAY)
	
	var camera_change_action := CameraChangeAction.new(self)
	rampage_charges -= 1
	
	var shield_action: AddFieldEffectAction = onCreateBaseFieldEffectAction(SHIELD_ID)
	onPushAction([camera_change_action, animation_action,
		StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, attack_value)),
		shield_action])
	
func getDefaultCharges() -> int:
	return 1
	
func onRegularReset() -> void:
	super()
	rampage_charges = getDefaultCharges()
	
func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	return super()
	
func getTierAttack() -> int:
	match tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
