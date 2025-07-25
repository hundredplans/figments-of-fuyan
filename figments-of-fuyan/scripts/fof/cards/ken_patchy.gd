extends CardGD

var on_hit_charges: int = 1


func onProcessAction(action: Action) -> void:
	super(action)
	if isValidOnHit(action) and on_hit_charges != 0:
		onPushAction(OnHitAction.new(self, action))

func onHit(_damage_action: DamageAction, _attack_action: AttackAction) -> void:
	if tier > 1: on_hit_charges = max(on_hit_charges - 1, 0)
	onStun(2)
	
#func onAscendedUpdated(state: bool) -> void:
	#super(state)
	#on_hit_charges = getDefaultCharges()
	
func getDescription(use_default_values: bool = false) -> String:
	if getTier() >= 2:
		return Helper.getDescription(super(), [on_hit_charges])
	return super(use_default_values)

func getDefaultCharges() -> int:
	return 1
	
func onRegularReset() -> void:
	super()
	on_hit_charges = getDefaultCharges()
	
func onSave() -> SavedDataCard:
	ability_save['on_hit_charges'] = on_hit_charges
	return super()
