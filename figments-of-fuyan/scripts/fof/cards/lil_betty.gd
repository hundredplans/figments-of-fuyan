extends CardGD

var turns_remaining: int = 0
const TURNS_MAX_DEFAULT: int = 4
const TURNS_MAX_ASCENDED: int = 3
const END_TURN_ACTION_DELAY: float = 2.0
const ENEMY_HIT_ACTION_DELAY: float = 1.0

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidEndOfTurn(action):
		onPushAction(EndTurnEffectAction.new(self, action))
	
func getDescription() -> String:
	return Helper.getDescription(super(), [turns_remaining])

func onSave() -> SavedDataCard:
	ability_save['turns_remaining'] = turns_remaining
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
	
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(END_TURN_ACTION_DELAY)
	var enemies: Array = getVisibleFieldCardsEnemies()
	
	var actions: Array = [CameraChangeAction.new(self), animation_action]
	var EnemyCard: CardGD = enemies.pick_random() if !enemies.is_empty() else null
	
	if EnemyCard != null:
		var damage_action := DamageAction.new(self, EnemyCard, 2, Game.DamageTypes.OTHER)
		damage_action.setActionDelay(ENEMY_HIT_ACTION_DELAY)
		actions += [CameraChangeAction.new(EnemyCard), damage_action, CameraChangeAction.new(self)]
	onPushAction(actions)
	
func getMaxTurns() -> int:
	return TURNS_MAX_DEFAULT if !getAscended() else TURNS_MAX_ASCENDED
