class_name FallDamageAction extends Action

var Card: CardGD
var StartTile: TileGD
var DestinationTile: TileGD
var damage: int

func _init(_Card: CardGD = null, _StartTile: TileGD = null, _DestinationTile: TileGD = null) -> void:
	super()
	Card = _Card
	StartTile = _StartTile
	DestinationTile = _DestinationTile

func onPreAction() -> void:
	onCheckFail()
	
func onPostAction() -> void:
	onPushAction(DamageAction.new(DestinationTile, Card, damage, Game.DamageTypes.FALL_DAMAGE))

func onCheckFail() -> void:
	damage = StartTile.getFallDamage(DestinationTile)
	if damage == 0: onFailAction()
