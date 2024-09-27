class_name MovementAction extends Action

var Card: CardGD
var DestinationTile: TileGD

func _init(_Card: CardGD = null, _DestinationTile: TileGD = null) -> void:
	super()
	Card = _Card
	DestinationTile = _DestinationTile

func onPreAction() -> void:
	if DestinationTile.movement_path.is_empty(): onFailAction()

func onPostAction() -> void:
	Card.onWalk()
	for i in range(1, DestinationTile.movement_path.size()):
		onAppendAction(MoveToTileAction.new(Card, DestinationTile.movement_path[i]))
	onAppendAction(MovementFinishAction.new(Card))
