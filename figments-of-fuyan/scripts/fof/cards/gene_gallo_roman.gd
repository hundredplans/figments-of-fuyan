extends CardGD

var on_hit_trigger_amount: int
const TRIGGER_ON_HIT_AMOUNT: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidForceOnHit(action):
		onForceAction(OnHitAction.new(self, action))
	
func getDescription() -> String:
	return Helper.getDescription(super(), [on_hit_trigger_amount])

func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	on_hit_trigger_amount += 1
	if on_hit_trigger_amount < TRIGGER_ON_HIT_AMOUNT: return
	else: on_hit_trigger_amount = 0
	
	damage_action.setIgnoreArmorShield(true)
	
func onRegularReset() -> void:
	super()
	on_hit_trigger_amount = getDefaultCharges()
	
func getDefaultCharges() -> int:
	return 0

func onSave() -> SavedDataCard:
	ability_save['on_hit_trigger_amount'] = on_hit_trigger_amount
	return super()
