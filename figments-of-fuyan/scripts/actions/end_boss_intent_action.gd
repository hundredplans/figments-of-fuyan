class_name EndBossIntentAction extends Action

var Card: CardGD
var allies: Array
var enemies: Array
func _init(_Card: CardGD = null, _allies: Array = [], _enemies: Array = []) -> void:
	super()
	Card = _Card
	allies = _allies
	enemies = _enemies
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var action := AITurnAction.new(Card, false, false, allies, enemies)
	action.setIsEndUseTypeBoss(true)
	onPushAction(action)
