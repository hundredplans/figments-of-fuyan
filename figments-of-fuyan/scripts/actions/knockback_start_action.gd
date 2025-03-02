class_name KnockbackStartAction extends Action

var Card: CardGD
var Applier: GameObjectGD
var knockback: int
var direction: int

func _init(_Card: CardGD = null, _Applier: GameObjectGD = null, _knockback: int = 0, _direction: int = 0) -> void:
	super()
	Card = _Card
	Applier = _Applier
	knockback = _knockback
	direction = _direction
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var cube_diagonal: Vector3i = Game.cube_directions[direction]
	var base_diagonal := Vector4i(cube_diagonal.x, cube_diagonal.y, cube_diagonal.z, 0)
	
	var coords: Vector4i = Card.getCoords()
	var tiles: Array = []
	var current_height: int = Card.getTile().getHeight()
	var deal_damage: bool = false
	
	for mult in range(1, knockback + 1):
		var diagonal: Vector4i = base_diagonal * mult
		var DiagonalTile: TileGD = Game.getTileAtHeightOrBelow(coords + diagonal)
		if DiagonalTile != null:
			if DiagonalTile.isSolid() or DiagonalTile.isOccupied():
				deal_damage = true
				break
			tiles.append(DiagonalTile)
			
		else: # If null search for tiles above
			DiagonalTile = Game.getTileAtHeightOrAbove(coords + diagonal)
			if DiagonalTile != null: deal_damage = true
			break
	
	var actions: Array = [ChangeTileRotationAction.new(Card, (direction + 3) % 6)]
	if !tiles.is_empty():
		actions.append(MovementAction.new(Card, [Card.getTile()] + tiles))
	if deal_damage: actions.append(DamageAction.new(Card, Card, Game.DamageTypes.OTHER))
	actions.append(KnockbackEndAction.new(Card))
	
	Card.setIsKnockback(true)
	onPushAction(actions)
