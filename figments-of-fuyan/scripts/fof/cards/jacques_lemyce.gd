extends CardGD

var is_stun_attack: bool
var rampage_charges: int = 1
const RAMPAGE_DELAY: float = 2.0

func getDescription() -> String:
	return Helper.getDescriptionNumeric(super(), [rampage_charges], [["RAMPAGE ", "[1]"]])

func onProcessAction(action: Action) -> void:
	super(action)
	if rampage_charges > 0 and isValidRampage(action):
		onPushAction(RampageAction.new(self, action))
	elif is_stun_attack and isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))
		
func getDefaultCharges() -> int:
	return 1
	
func onRegularReset() -> void:
	super()
	rampage_charges = getDefaultCharges()
	
func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	ability_save['is_stun_attack'] = is_stun_attack
	return super()
	
func onRampage(_death_action: DeathAction) -> void:
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(RAMPAGE_DELAY)
	
	var camera_change_action := CameraChangeAction.new(self)
	rampage_charges -= 1
	
	onPushAction([camera_change_action, animation_action])
	is_stun_attack = true
		
func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	is_stun_attack = false
	for Defender: CardGD in damage_action.Defenders:
		Defender.onStun(1)
