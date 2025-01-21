extends CardGD

var field_effect_public_id: int
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidWhenHealed(action) and field_effect_public_id == 0:
		onPushAction(WhenHealedAction.new(self, action))
	elif isValidOnHit(action) and field_effect_public_id > 0:
		onPushAction(OnHitAction.new(self, action))
	
func getDescription() -> String:
	return super()

func onWhenHealed(_action: StatAction) -> void:
	setIdleAbility(true)
	
	var FieldEffect: FieldEffectGD = SavedData.onLoadModel(SavedDataFieldEffect.new(10, true), self)
	onAddFieldEffect(FieldEffect, self)
	field_effect_public_id = FieldEffect.public_id
	
	onIdle()

func onHit(_damage_action: DamageAction, attack_action: AttackAction) -> void:
	setIdleAbility(false)
	
	var FieldEffect: FieldEffectGD = Game.onFindPublicIDObject(field_effect_public_id)
	if FieldEffect != null:
		onRemoveFieldEffect(FieldEffect)
		field_effect_public_id = 0
	
	for Card in attack_action.Defenders.filter(func(x: GameObjectGD): return x is CardGD):
		Card.onCreateBaseStatusEffect(4)

func onSave() -> SavedDataCard:
	ability_save['field_effect_public_id'] = field_effect_public_id
	return super()
