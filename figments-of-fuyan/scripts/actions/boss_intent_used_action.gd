class_name BossIntentUsedAction extends Action

var boss_intent: BossIntent
var use_type: EpicCardGD.UseType
var actions: Array
var enemies: Array
var allies: Array

func _init(_boss_intent: BossIntent, _use_type: EpicCardGD.UseType, _actions: Array, _enemies: Array, _allies: Array) -> void:
	super()
	boss_intent = _boss_intent
	use_type = _use_type
	actions = _actions
	enemies = _enemies
	allies = _enemies
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	if use_type == EpicCardGD.UseType.START:
		actions.push_front(ChangeTurnStateAction.new(BossCard, Game.TurnStates.ACTIVE))
		actions.append(EndBossIntentAction.new(BossCard, allies, enemies))
		
	if use_type == EpicCardGD.UseType.END:
		BossCard.boss_datastore.boss_intent_used_this_turn = true
		actions.append(BossIntentFinishedAction.new(BossCard, !enemies.is_empty()))
	
	BossCard.onIntentUsed(boss_intent, use_type, actions)
	onPushAction(actions)
