extends CardGD

const ABILITY_DELAY: float = 2.0
const QUENTIN_BULLETS_FIELD_EFFECT_ID: int = 11

var bullets: int
var quentins_bullets_public_id: int
# -> +1 hp

#RANGED [1-2]; Has x/4 Bullets in chamber; Has to Reload to refresh bullets
#RELOAD - ABILITY: If an enemy is in vision; Gain [1] Bullet and STUN self
# Shop is 15% more expensive cause he's a criminal - REMOVE THIS
# Tools are 15% more expensive
	
const SHOP_PRICE_MULT: float = 1.15
const DISARM_ID: int = 4
	
func onFofInit() -> void:
	super()
	bullets = 2
	
func onProcessAction(action: Action):
	super(action)
	if !action.post:
		if action is AttackAction and bullets == 0:
			action.onFailAction() # Just in case me
		elif action is GetShopPriceAction:
			action.onMult(SHOP_PRICE_MULT)
		elif action is RemoveStatusEffectAction and action.StatusEffect.info.id == DISARM_ID and bullets == 0:
			action.onFailAction()
		
	elif action.post:
		if action is AwakenAction and action.Card == self:
			quentins_bullets_public_id = onCreateBaseFieldEffect(QUENTIN_BULLETS_FIELD_EFFECT_ID, bullets).public_id
			
	if isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))
	
func onHit(_damage_action: DamageAction, _attack_action: AttackAction) -> void:
	setBullets(-1)
	if bullets == 0:
		onCreateBaseStatusEffect(DISARM_ID, -1)

func onSave() -> SavedDataCard:
	ability_save['bullets'] = bullets
	ability_save['quentins_bullets_public_id'] = quentins_bullets_public_id
	return super()
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [bullets, getMaxBullets()])

func getActiveEffectDescription(active_effect: ActiveEffectDatastore, description: String) -> String:
	if active_effect.name != "Reload": return super(active_effect, description)
	return Helper.getDescription(description, [bullets])

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Reload":
		return ActiveEffectTiles.new([Tile], [Tile])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Reload":
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		var actions: Array = [animation_action]
		
		setBullets(1)
		actions.append(RemoveStatusEffectAction.new(getStatusEffect(DISARM_ID)))
		actions += getStunActions()
		onPushAction(actions)
	
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return bullets == getMaxBullets() or !inEnemyVision()
	
func setBullets(delta: int) -> void:
	bullets += delta
	Game.onFindPublicIDObject(quentins_bullets_public_id).setCharges(bullets)
	update_active_effect_description.emit()

func getMaxBullets() -> int:
	return 2 if getTier() == 1 else 4

func onRetiered(tier: int) -> void:
	super(tier)
	if tier == 2:
		bullets += 2
