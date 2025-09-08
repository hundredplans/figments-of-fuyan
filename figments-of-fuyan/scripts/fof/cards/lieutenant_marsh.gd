extends CardGD

var affected_cards: Array = []
var affected_cards_public_ids: Array = []
var lieutenants_aura_public_id: int = 0
const LIEUTENANTS_AURA_ID: int = 18

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidArrive(action):
		onPushAction(ArriveAction.new(self, action))
	
	if isValidForceOnHit(action):
		onForceAction(OnHitAction.new(self, action))
		
	if action.post:
		if card_place == Game.CardPlaces.FIELD:
			if action is VisionNewUnitAction and action.Discoverer == self and action.Discovered.isAlly(team) and action.Discovered != self:
				if action.enter_vision and action.Discovered not in affected_cards:
					onAddToAura(action.Discovered)
				elif !action.enter_vision and action.Discovered in affected_cards:
					onRemoveFromAura(action.Discovered)
		
		if action is DeathAction and action.Defender in affected_cards:
			onRemoveFromAura(action.Defender)
	elif !action.post:
		if action is GetDamageAction and action.Damager == self and action.damage_type == Game.DamageTypes.ATTACK:
			action.onAdd(getDamage())
			
func onArrivePre(_action: AwakenAction) -> void: pass
func onArrive(_action: AwakenAction) -> void:
	lieutenants_aura_public_id = onCreateBaseFieldEffect(LIEUTENANTS_AURA_ID, 0).public_id
					
func onRegularReset() -> void:
	super()
	affected_cards = []
	lieutenants_aura_public_id = 0
					
func onAddToAura(Card: CardGD) -> void:
	affected_cards.append(Card)
	var LieutenantsFieldEffect: FieldEffectGD = Game.onFindPublicIDObject(lieutenants_aura_public_id)
	if LieutenantsFieldEffect == null: assert(false); return
	LieutenantsFieldEffect.setCharges(getDamage())
	
func onRemoveFromAura(Card: CardGD) -> void:
	affected_cards.erase(Card)
	var LieutenantsFieldEffect: FieldEffectGD = Game.onFindPublicIDObject(lieutenants_aura_public_id)
	if LieutenantsFieldEffect == null: assert(false); return
	LieutenantsFieldEffect.setCharges(getDamage())

func getDamage() -> int:
	return affected_cards.size()

func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	damage_action.damage += getDamage()
	
func onSave() -> SavedDataCard:
	ability_save['affected_cards_public_ids'] = affected_cards.map(func(x: CardGD): return x.public_id)
	ability_save['lieutenants_aura_public_id'] = lieutenants_aura_public_id
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	affected_cards = affected_cards_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
