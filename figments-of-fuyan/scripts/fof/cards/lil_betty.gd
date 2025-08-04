extends CardGD

var lil_betty_turns_public_id: int = 0
var turns_remaining: int = 0

const END_TURN_ACTION_DELAY: float = 2.0
const ENEMY_HIT_ACTION_DELAY: float = 1.0
const LIL_BETTY_TURNS_ID: int = 14

const TIER_ONE_DAMAGE: int = 2
const TIER_TWO_DAMAGE: int = 2
const TIER_THREE_DAMAGE: int = 2
const TIER_FOUR_DAMAGE: int = 3

const TIER_ONE_TURNS: int = 4
const TIER_TWO_TURNS: int = 3
const TIER_THREE_TURNS: int = 3
const TIER_FOUR_TURNS: int = 3

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidEndOfTurn(action):
		onPushAction(EndTurnEffectAction.new(self, action))
	elif isValidArrive(action):
		onPushAction(ArriveAction.new(self, action))
		
func onArrivePre(_action: AwakenAction) -> void:
	pass
		
func onArrive(_action: AwakenAction) -> void:
	lil_betty_turns_public_id =  onCreateBaseFieldEffect(LIL_BETTY_TURNS_ID).public_id
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [turns_remaining])

func onSave() -> SavedDataCard:
	ability_save['turns_remaining'] = turns_remaining
	ability_save['lil_betty_turns_public_id'] = lil_betty_turns_public_id
	return super()
	
func getDefaultCharges() -> int:
	return 0
	
func onRegularReset() -> void:
	super()
	turns_remaining = getDefaultCharges()
	
func onEndTurnEffect(_action: ChangeTurnStateAction) -> void:
	turns_remaining += 1
	var skip: bool = false
	if turns_remaining >= getTierTurns(): turns_remaining = 0; skip = true
	
	var FieldEffect: FieldEffectGD = Game.onFindPublicIDObject(lil_betty_turns_public_id)
	if FieldEffect != null:
		FieldEffect.onForceUpdateDisplayNumber()
		
	if !skip and turns_remaining < getTierTurns(): return
	
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(END_TURN_ACTION_DELAY)
	var enemies: Array = getVisibleFieldCardsEnemies()
	
	var actions: Array = [CameraChangeAction.new(self), animation_action]
	var EnemyCard: CardGD = enemies.pick_random() if !enemies.is_empty() else null
	
	if EnemyCard != null:
		var damage_action := DamageAction.new(self, EnemyCard, getTierDamage(), Game.DamageTypes.OTHER)
		damage_action.setActionDelay(ENEMY_HIT_ACTION_DELAY)
		actions += [CameraChangeAction.new(EnemyCard), damage_action, CameraChangeAction.new(self)]
		
	onPushAction(actions)
	
func getTierTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
	
func getTierDamage() -> int:
	match tier:
		1: return TIER_ONE_DAMAGE
		2: return TIER_TWO_DAMAGE
		3: return TIER_THREE_DAMAGE
		4: return TIER_FOUR_DAMAGE
	return 0
