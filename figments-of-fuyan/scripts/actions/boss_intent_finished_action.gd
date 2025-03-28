class_name BossIntentFinishedAction extends Action

var Card: EpicCardGD
var was_in_vision: bool
func _init(_Card: EpicCardGD, _was_in_vision: bool = false) -> void:
	super()
	Card = _Card
	was_in_vision = _was_in_vision
	
func onPostAction() -> void:
	Card.boss_datastore.setIntentDuration(Card.boss_datastore.getIntentDuration() - 1)
	if Card.boss_datastore.getIntentDuration() == 0:
		var enemies: Array = Card.getVisibleFieldCardsEnemies()
		var allies: Array = Card.getVisibleFieldCardsAllies()
		
		var boss_intent: BossIntent = Card.boss_intent
		var cooldown: int = boss_intent.default_cooldown
		
		if !was_in_vision: # If he never saw an enemy even once
			if boss_intent.combat_type == BossIntent.CombatType.IN_COMBAT: cooldown = boss_intent.default_cooldown
			else: cooldown = boss_intent.default_cooldown if boss_intent.off_vision_use_cooldown else 0

		Card.boss_datastore.boss_intent_name_to_cooldown[boss_intent.name] = cooldown
		
		var new_boss_intent: BossIntent = Card.onChangeBossIntent(Card.onFilterBossIntents(enemies, allies), enemies, allies)
		var actions: Array = [ChangeBossIntentAction.new(new_boss_intent), ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED), AITurnStartAction.new(Card.team)]
		onPushAction(actions)
	else:
		onPushAction([ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED), AITurnStartAction.new(Card.team)])
	
