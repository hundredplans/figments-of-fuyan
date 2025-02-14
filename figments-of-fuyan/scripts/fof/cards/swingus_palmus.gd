extends CardGD

var swingus_field_effect_public_id: int
const SWINGUS_ON_HIT_FIELD_EFFECT_ID: int = 8

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if isValidOnHit(action):
			onPushAction(OnHitAction.new(self, action))
	
	elif !action.post:
		if action is GetDamageAction and action.Damager == self and action.damage_type == Game.DamageTypes.ATTACK and swingus_field_effect_public_id > 0:
			action.onAdd(getExtraDamage())
	
func onHit(_damage_action: DamageAction, _attack_action: AttackAction) -> void:
	if swingus_field_effect_public_id == 0:
		setIdleAbility(true)
		setAttackAbility(true)
		
		swingus_field_effect_public_id = onCreateBaseFieldEffect(SWINGUS_ON_HIT_FIELD_EFFECT_ID).public_id
		return
		
	setIdleAbility(false)
	setAttackAbility(false)

	var actions: Array = [
		StatAction.new([StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH], [1, 1])]),
		RemoveFieldEffectAction.new(Game.onFindPublicIDObject(swingus_field_effect_public_id))]
		
	swingus_field_effect_public_id = 0
	onPushAction(actions)
	
func getDescription() -> String:
	return super()

func getAttackDamage() -> int:
	var default_damage: int = super()
	if swingus_field_effect_public_id > 0: return default_damage + getExtraDamage()
	return default_damage
	
func getExtraDamage() -> int:
	return 2 if !ascended else 4

func onSave() -> SavedDataCard:
	ability_save['swingus_field_effect_public_id'] = swingus_field_effect_public_id
	return super()
	
func onReset(override: bool = false) -> void:
	super(override)
	swingus_field_effect_public_id = 0
