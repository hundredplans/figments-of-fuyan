extends CardGD

var swingus_field_effect_public_id: int
const SWINGUS_ON_HIT_FIELD_EFFECT_ID: int = 8

const TIER_ONE_DAMAGE: int = 2
const TIER_TWO_DAMAGE: int = 4
const TIER_THREE_DAMAGE: int = 4
const TIER_FOUR_DAMAGE: int = 4

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
		swingus_field_effect_public_id = onCreateBaseFieldEffect(SWINGUS_ON_HIT_FIELD_EFFECT_ID).public_id
		return
		
	var modifier: String = "Ability" if swingus_field_effect_public_id == 0 else ""
	var actions: Array = [
		AnimationModifierAction.new(self, "Idle", modifier),
		AnimationModifierAction.new(self, "Attack", modifier),
		StatAction.new([StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [1, 1, 1])]),
		RemoveFieldEffectAction.new(Game.onFindPublicIDObject(swingus_field_effect_public_id))]
		
	swingus_field_effect_public_id = 0
	onPushAction(actions)

func getAttackDamage() -> int:
	var default_damage: int = super()
	if swingus_field_effect_public_id > 0: return default_damage + getExtraDamage()
	return default_damage
	
func getExtraDamage() -> int:
	return getTierDamage()

func onSave() -> SavedDataCard:
	ability_save['swingus_field_effect_public_id'] = swingus_field_effect_public_id
	return super()
	
func onRegularReset() -> void:
	super()
	
	swingus_field_effect_public_id = 0
	var actions: Array = [
		AnimationModifierAction.new(self, "Idle", ""),
		AnimationModifierAction.new(self, "Attack", "")
	]
	onPushAction(actions)

func getTierDamage() -> int:
	match tier:
		1: return TIER_ONE_DAMAGE
		2: return TIER_TWO_DAMAGE
		3: return TIER_THREE_DAMAGE
		4: return TIER_FOUR_DAMAGE
	return 0
