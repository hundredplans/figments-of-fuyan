extends CardGD

var field_effect_public_id: int = 0
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and field_effect_public_id == 0:
		onPushAction(RampageAction.new(self, action))
	elif isValidWhenHealed(action) and field_effect_public_id > 0:
		onHealed(action)
	
func getDescription() -> String:
	return super()
	
func onRampage(death_action: DeathAction) -> void:
	var FieldEffect: FieldEffectGD = onAddBaseFieldEffect(2, self)
	field_effect_public_id = FieldEffect.public_id
	
	onAbility()
	setIdleAbility(true)
	
func onHealed(action: StatAction) -> void:
	for stat_info in action.stat_infos.filter(func(x: StatInfo): return x.Card == self):
		for i in range(stat_info.types.size()):
			if stat_info.types[i] == Game.Stats.HEALTH and stat_info.values[i] > 0:
				stat_info.values[i] *= (2 if !ascended else 99)
	
	onRemoveFieldEffect(Game.onFindPublicIDObject(field_effect_public_id))
	setIdleAbility(false)
	field_effect_public_id = 0


func onSave() -> SavedDataCard:
	ability_save['field_effect_public_id'] = field_effect_public_id
	return super()
