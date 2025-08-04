extends CardGD

var on_hit_trigger_amount: int

const TIER_ONE_TRIGGER_AMOUNT: int = 2
const TIER_TWO_TRIGGER_AMOUNT: int = 2
const MINIMUM_TIER_TRIGGER_INSTANTLY: int = 3

const PIERCING_SHOT_ID: int = 13

var piercing_shot_public_id: int = 0

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidForceOnHit(action):
		onForceAction(OnHitAction.new(self, action))
	
	if !action.post:
		if action is GetDamageAction and on_hit_trigger_amount == 1:
			action.setIgnoreArmorShield(true)
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [on_hit_trigger_amount])

func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	if tier < MINIMUM_TIER_TRIGGER_INSTANTLY:
		on_hit_trigger_amount += 1
		if on_hit_trigger_amount == 1:
			piercing_shot_public_id = onCreateBaseFieldEffect(PIERCING_SHOT_ID).public_id
		if on_hit_trigger_amount < getTriggerAmount(): return
		
	on_hit_trigger_amount = 0
	if piercing_shot_public_id > 0:
		var PiercingShotFieldEffect: FieldEffectGD = Game.onFindPublicIDObject(piercing_shot_public_id)
		onPushAction(RemoveFieldEffectAction.new(PiercingShotFieldEffect))
	
	damage_action.setIgnoreArmorShield(true)
	
func onRegularReset() -> void:
	super()
	on_hit_trigger_amount = getDefaultCharges()
	piercing_shot_public_id = 0
	
func getDefaultCharges() -> int:
	return 0

func onSave() -> SavedDataCard:
	ability_save['on_hit_trigger_amount'] = on_hit_trigger_amount
	ability_save['piercing_shot_public_id'] = piercing_shot_public_id
	return super()

func getTriggerAmount() -> int:
	match tier:
		1: return TIER_ONE_TRIGGER_AMOUNT
		2: return TIER_TWO_TRIGGER_AMOUNT
	return 0
