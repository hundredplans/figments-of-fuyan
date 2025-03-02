class_name BossIntentFinishedAction extends Action

var Card: BossCardGD
func _init(_Card: BossCardGD) -> void:
	super()
	Card = _Card 
	
func onPostAction() -> void:
	var enemies: Array = Card.getVisibleFieldCardsEnemies()
	var allies: Array = Card.getVisibleFieldCardsAllies()
	
	Card.boss_datastore.boss_intent_name_to_cooldown[Card.boss_intent.name] = Card.boss_intent.default_cooldown if Card.isLevelVisible() else 0
	Card.boss_datastore.onResetConditionResults()
	var boss_intent: BossIntent = Card.onChangeBossIntent(Card.onFilterBossIntents(enemies, allies), enemies, allies)
	
	var actions: Array = [ChangeBossIntentAction.new(boss_intent), ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED), AITurnStartAction.new(Card.team)]
	onPushAction(actions)
	
