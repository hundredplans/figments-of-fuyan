extends CardGD

const MAX_BULLETS: int = 4
var bullets: int = 4
var quentins_bullets_public_id: int
# -> +1 hp

#RANGED [1-2]; Has x/4 Bullets in chamber; Has to Reload to refresh bullets
#RELOAD - ABILITY: If an enemy is in vision; Gain [1] Bullet and STUN self
# Shop is 15% more expensive cause he's a criminal
	
func onProcessAction(action: Action):
	super(action)
	if !action.post:
		if action is AttackAction and bullets == 0:
			action.onFailAction()
	elif action.post:
		if action is AwakenAction and action.Card == self:
			var FieldEffect: FieldEffectGD = SavedData.onLoadModel(SavedDataFieldEffect.new(11, true), self)
			quentins_bullets_public_id = FieldEffect.public_id
			action.Card.onAddFieldEffect(FieldEffect, self)
			FieldEffect.setCharges(bullets)
	
	if isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))
	
func onHit(_damage_action: DamageAction, _attack_action: AttackAction) -> void:
	setBullets(-1)

func onSave() -> SavedDataCard:
	ability_save['bullets'] = bullets
	ability_save['quentins_bullets_public_id'] = quentins_bullets_public_id
	return super()
	
func getDescription() -> String:
	return Helper.getDescription(super(), [bullets])

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
		setBullets(1)
		onStun()
		onAbility()
	
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return bullets == 4 or !inEnemyVision()
	
func setBullets(delta: int) -> void:
	bullets += delta
	Game.onFindPublicIDObject(quentins_bullets_public_id).setCharges(bullets)
	update_active_effect_description.emit()
