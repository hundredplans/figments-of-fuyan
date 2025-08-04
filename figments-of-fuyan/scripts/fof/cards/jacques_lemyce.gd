extends CardGD

var mace_smash_public_id: int
var is_stun_attack: bool
var rampage_charges: int = 1
const RAMPAGE_DELAY: float = 2.0
const MACE_SMASH_ID: int = 15

const TIER_ONE_CHARGES: int = 1
const TIER_TWO_CHARGES: int = -1
const TIER_THREE_CHARGES: int = -1
const TIER_FOUR_CHARGES: int = -1

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [rampage_charges])

func onProcessAction(action: Action) -> void:
	super(action)
	if rampage_charges != 0 and isValidRampage(action):
		onPushAction(RampageAction.new(self, action))
	elif is_stun_attack and isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))
		
func getDefaultCharges() -> int:
	return getTierCharges()
	
func onRegularReset() -> void:
	super()
	rampage_charges = getDefaultCharges()
	
func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	ability_save['is_stun_attack'] = is_stun_attack
	ability_save['mace_smash_public_id'] = mace_smash_public_id
	return super()
	
func onRampage(_death_action: DeathAction) -> void:
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(RAMPAGE_DELAY)
	
	var camera_change_action := CameraChangeAction.new(self)
	
	if rampage_charges > 0:
		rampage_charges -= 1
		
	var add_field_effect_action := onCreateBaseFieldEffectAction(MACE_SMASH_ID)
	mace_smash_public_id = add_field_effect_action.FieldEffect.public_id
	onPushAction([camera_change_action, animation_action, add_field_effect_action])
	is_stun_attack = true
		
func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	is_stun_attack = false
	for Defender: CardGD in damage_action.Defenders:
		Defender.onStun(1)
	
	onPushAction(RemoveFieldEffectAction.new(Game.onFindPublicIDObject(mace_smash_public_id)))

func getTierCharges() -> int:
	match tier:
		1: return TIER_ONE_CHARGES
		2: return TIER_TWO_CHARGES
		3: return TIER_THREE_CHARGES
		4: return TIER_FOUR_CHARGES
	return 0
