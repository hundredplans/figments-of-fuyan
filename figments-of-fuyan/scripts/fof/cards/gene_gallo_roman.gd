extends CardGD

var on_hit_trigger_amount: int
const TRIGGER_ON_HIT_AMOUNT: int = 2
const PIERCING_SHOT_ID: int = 13

var piercing_shot_public_id: int = 0

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidForceOnHit(action):
		onForceAction(OnHitAction.new(self, action))
	
	if !action.post:
		if action is GetDamageAction and on_hit_trigger_amount == 1:
			action.setIgnoreArmorShield(true)
	
func getDescription() -> String:
	return Helper.getDescription(super(), [on_hit_trigger_amount])

func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	on_hit_trigger_amount += 1
	if on_hit_trigger_amount == 1:
		piercing_shot_public_id = onCreateBaseFieldEffect(PIERCING_SHOT_ID).public_id
	
	if on_hit_trigger_amount < TRIGGER_ON_HIT_AMOUNT: return
	else:
		on_hit_trigger_amount = 0
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
