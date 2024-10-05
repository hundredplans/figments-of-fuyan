class_name VisionAction extends Action

var Card: CardGD

func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
	
func onPostAction() -> void:
	var visible_game_objects: Array = [] if Card.team != 0 else Game.getTeamVision(Card.team)
	Card.visible_game_objects = {}
	Card.onUpdateVision()
	
	if Card.team == 0:
		var new_visible_game_objects: Array = Game.getTeamVision(Card.team)
		var not_in_vision: Array = visible_game_objects.filter(func(x: GameObjectGD): return x not in new_visible_game_objects)
		var now_in_vision: Array = new_visible_game_objects.filter(func(x: GameObjectGD): return x not in visible_game_objects)
	
		onPushAction(LevelVisibleAction.new(false, not_in_vision))
		onPushAction(LevelVisibleAction.new(true, now_in_vision))
			
	
