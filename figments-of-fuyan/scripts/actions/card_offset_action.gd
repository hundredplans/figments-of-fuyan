class_name CardOffsetAction extends Action

var Card: CardGD
var position: Vector3
var rotation: Vector3

func _init(_Card: CardGD = null, _position := Vector3.ZERO, _rotation := Vector3.ZERO) -> void:
	Card = _Card
	position = _position
	rotation = _rotation
	
func onPostAction() -> void:
	Card.card_offset.setPositionOffset(position)
	Card.card_offset.setRotationOffset(rotation)
	Card.setPositionToTile(Card.getTile())
	Card.setTileRotation(Card.tile_rotation)
