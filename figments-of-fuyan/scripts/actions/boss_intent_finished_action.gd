class_name BossIntentFinishedAction extends Action

var Card: BossCardGD

func _init(_Card: BossCardGD) -> void:
	super()
	Card = _Card 
	
func onPostAction() -> void:
	var enemies: Array = Card.getVisibleFieldCardsEnemies()
	var allies: Array = Card.getVisibleFieldCardsAllies()
	
	var boss_intent: BossIntent = Card.boss_intent
	var cooldown: int = boss_intent.default_cooldown
	
	if !Card.isLevelVisible():
		if boss_intent.combat_type == BossIntent.CombatType.IN_COMBAT: cooldown = boss_intent.default_cooldown
		else: cooldown = boss_intent.default_cooldown if boss_intent.off_vision_use_cooldown else 0

	Card.boss_datastore.boss_intent_name_to_cooldown[boss_intent.name] = cooldown
	Card.boss_datastore.onResetConditionResults()
	
	var new_boss_intent: BossIntent = Card.onChangeBossIntent(Card.onFilterBossIntents(enemies, allies), enemies, allies)
	var actions: Array = [ChangeBossIntentAction.new(new_boss_intent), ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED), AITurnStartAction.new(Card.team)]
	onPushAction(actions)
	
