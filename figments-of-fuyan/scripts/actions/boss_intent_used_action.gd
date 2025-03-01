class_name BossIntentUsedAction extends Action

var boss_intent: BossIntent
var use_type: BossCardGD.UseType
var actions: Array
var enemies: Array
var allies: Array

func _init(_boss_intent: BossIntent, _use_type: BossCardGD.UseType, _actions: Array, _enemies: Array, _allies: Array) -> void:
	super()
	boss_intent = _boss_intent
	use_type = _use_type
	actions = _actions
	enemies = _enemies
	allies = _enemies
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var BossCard: BossCardGD = Game.getLevel().getBoss()
	if use_type == BossCardGD.UseType.START:
		actions.push_front(ChangeTurnStateAction.new(BossCard, Game.TurnStates.ACTIVE))
		var ai_turn_action := AITurnAction.new(BossCard, false, false, allies, enemies)
		ai_turn_action.setIsEndUseTypeBoss(true)
		actions.append(ai_turn_action)
		
	if use_type == BossCardGD.UseType.END:
		BossCard.boss_datastore.boss_intent_used_this_turn = true
		actions.append(BossIntentFinishedAction.new(BossCard))
	
	BossCard.onIntentUsed(boss_intent, use_type, actions)
	onPushAction(actions)
