class_name MovementFinishAction extends Action

var tiles: Array
var Card: CardGD

func _init(_Card: CardGD = null, _tiles: Array = []) -> void:
	Card = _Card
	tiles = _tiles
	
func onPostAction() -> void:
	for Tile in tiles:
		Tile.is_card_moving = false
		Tile.setOutlineMaterial()
	Card.onIdle()
