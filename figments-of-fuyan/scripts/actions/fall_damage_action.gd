class_name FallDamageAction extends Action

var Card: CardGD
var Tile: TileGD
var damage: int

func _init(_Card: CardGD = null, _Tile: TileGD = null) -> void:
	super()
	Card = _Card
	Tile = _Tile

func onPreAction() -> void:
	onCheckFail()
	
func onPostAction() -> void:
	onPushAction(DamageAction.new(Tile, Card, damage, Game.DamageTypes.FALL_DAMAGE))

func onCheckFail() -> void:
	damage = Tile.getFallDamage(Card.Tile)
	if damage == 0: onFailAction()
