class_name LevelVisibleAction extends Action

var game_objects: Array
var state: bool
var smart_vision: bool # Also reveals occupied objects and Cards for tiles

func _init(_state: bool = false, _game_objects: Array = [], _smart_vision: bool = true) -> void:
	super()
	state = _state
	game_objects = _game_objects
	smart_vision = _smart_vision
	
func onPostAction() -> void:
	var tile_to_card: Dictionary = {}
	if smart_vision:
		for Card in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
			tile_to_card[Card.Tile] = Card
		
	for GameObject in game_objects:
		if smart_vision:
			if GameObject is ObjectGD:
				for Tile in GameObject.occupied_tiles:
					if tile_to_card.has(Tile):
						if tile_to_card[Tile].level_visible: state = true
						tile_to_card[Tile].setLevelVisible(state)
					Tile.setLevelVisible(state)
					
			elif GameObject is TileGD:
				for Obj in GameObject.occupied_objects: Obj.setLevelVisible(state)
				if tile_to_card.has(GameObject): tile_to_card[GameObject].setLevelVisible(state)
			elif GameObject is CardGD:
				GameObject.Tile.setLevelVisible(state)
		GameObject.setLevelVisible(state)
