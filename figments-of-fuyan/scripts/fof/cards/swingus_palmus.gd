extends CardGD

var swingus_field_effect_public_id: int
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
		setAttackAbility(true, false)
		
		swingus_field_effect_public_id = onAddBaseFieldEffect(8, self).public_id
		return
		
	setIdleAbility(false)
	setAttackAbility(false, false)
	onRemoveFieldEffect(Game.onFindPublicIDObject(swingus_field_effect_public_id))
	swingus_field_effect_public_id = 0
	onPushAction(
		StatAction.new([
			StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH], [1, 1])
		])
	)
	
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
