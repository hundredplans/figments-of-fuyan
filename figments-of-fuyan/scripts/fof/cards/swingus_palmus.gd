extends CardGD

var swingus_field_effect_public_id: int
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))
	
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
			StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.HEALTH], [1, 1])
		])
	)
	
func getDescription() -> String:
	return super()

func getAttackDamage() -> int:
	var default_damage: int = super()
	if swingus_field_effect_public_id > 0: return default_damage + (2 if !ascended else 4)
	return default_damage

func onSave() -> SavedDataCard:
	ability_save['swingus_field_effect_public_id'] = swingus_field_effect_public_id
	return super()
