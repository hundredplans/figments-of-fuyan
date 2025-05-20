extends CardGD

var lil_betty_turns_public_id: int = 0
var turns_remaining: int = 0
const TURNS_MAX_DEFAULT: int = 4
const TURNS_MAX_ASCENDED: int = 3
const END_TURN_ACTION_DELAY: float = 2.0
const ENEMY_HIT_ACTION_DELAY: float = 1.0
const LIL_BETTY_TURNS_ID: int = 14

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidEndOfTurn(action):
		onPushAction(EndTurnEffectAction.new(self, action))
	elif isValidArrive(action):
		onPushAction(ArriveAction.new(self, action))
		
func onArrivePre(_action: AwakenAction) -> void:
	pass
		
func onArrive(action: AwakenAction) -> void:
	lil_betty_turns_public_id =  onCreateBaseFieldEffect(LIL_BETTY_TURNS_ID, -1, getMaxTurns()).public_id
	
func getDescription() -> String:
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
	
func onEndTurnEffect(action: ChangeTurnStateAction) -> void:
	turns_remaining += 1
	if turns_remaining < getMaxTurns(): return
	else: turns_remaining = 0
	
	var remove_field_effect_action := RemoveFieldEffectAction.new(Game.onFindPublicIDObject(lil_betty_turns_public_id))
	var add_field_effect_action := onCreateBaseFieldEffectAction(LIL_BETTY_TURNS_ID, 0, getMaxTurns())
	lil_betty_turns_public_id = add_field_effect_action.FieldEffect.public_id
	
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(END_TURN_ACTION_DELAY)
	var enemies: Array = getVisibleFieldCardsEnemies()
	
	var actions: Array = [CameraChangeAction.new(self), animation_action]
	var EnemyCard: CardGD = enemies.pick_random() if !enemies.is_empty() else null
	
	if EnemyCard != null:
		var damage_action := DamageAction.new(self, EnemyCard, 2, Game.DamageTypes.OTHER)
		damage_action.setActionDelay(ENEMY_HIT_ACTION_DELAY)
		actions += [CameraChangeAction.new(EnemyCard), damage_action, CameraChangeAction.new(self)]
		
	actions += [remove_field_effect_action, add_field_effect_action]
	onPushAction(actions)
	
func getMaxTurns() -> int:
	return TURNS_MAX_DEFAULT if !getAscended() else TURNS_MAX_ASCENDED
