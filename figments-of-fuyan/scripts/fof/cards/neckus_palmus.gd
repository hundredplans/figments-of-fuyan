extends CardGD

const NECKUS_PALMUS_FIELD_EFFECT_ID: int = 10
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
	
	field_effect_public_id = onCreateBaseFieldEffect(NECKUS_PALMUS_FIELD_EFFECT_ID).public_id
	onIdle()

func onHit(_damage_action: DamageAction, attack_action: AttackAction) -> void:
	setIdleAbility(false)
	
	var FieldEffect: FieldEffectGD = Game.onFindPublicIDObject(field_effect_public_id)
	if FieldEffect != null:
		onPushAction(RemoveFieldEffectAction.new(FieldEffect))
		field_effect_public_id = 0
	
	for Card in attack_action.Defenders.filter(func(x: GameObjectGD): return x is CardGD):
		Card.onCreateBaseStatusEffect(4)

func onSave() -> SavedDataCard:
	ability_save['field_effect_public_id'] = field_effect_public_id
	return super()
