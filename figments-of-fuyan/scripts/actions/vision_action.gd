class_name VisionAction extends Action

var Card: CardGD
var old_team_vision: Array = []
var old_card_visible_game_objects: Array = []
var new_card_visible_game_objects: Array = []

func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
	
func onPreAction() -> void:
	old_card_visible_game_objects = Card.getVisibleGameObjects()
	old_team_vision = Game.getTeamVision(Card.team)
	new_card_visible_game_objects = Card.onUpdateVision()
	
	if Card.isAlly(0):
		for FieldCard in Game.getEnemyUnits(0):
			if FieldCard in new_card_visible_game_objects: # Card visible, important this is not an and
				if FieldCard.Tile not in new_card_visible_game_objects:
					new_card_visible_game_objects.append(FieldCard.Tile)
			elif FieldCard.Tile in new_card_visible_game_objects:
				new_card_visible_game_objects.append(FieldCard.Tile)
	
func onPostAction() -> void:
	Card.visible_game_objects = {}
	for GameObject in new_card_visible_game_objects:
		Card.visible_game_objects[GameObject] = null 
		
	if Card.isAlly(0):
		var new_team_vision: Array = Game.getTeamVision(0)
		
		var not_in_vision: Array = old_team_vision.filter(func(x: GameObjectGD): return x not in new_team_vision)
		var now_in_vision: Array = new_team_vision.filter(func(x: GameObjectGD): return x not in old_team_vision)
	
		onPushAction(LevelVisibleAction.new(false, not_in_vision), false)
		onPushAction(LevelVisibleAction.new(true, now_in_vision), false)
			
	
