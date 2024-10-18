class_name MoveToTileAction extends Action

enum MOVEMENT_TYPES {REGULAR, RAMP, JUMP, FALL}
var Card: CardGD
var DestinationTile: TileGD
var movement_type: MOVEMENT_TYPES
var fall_time: float
var delay: float

func isJumpFall() -> bool:
	return movement_type == MOVEMENT_TYPES.JUMP or movement_type == MOVEMENT_TYPES.FALL

func _init(_Card: CardGD = null, _DestinationTile: TileGD = null) -> void:
	super()
	Card = _Card
	DestinationTile = _DestinationTile

func getDelay() -> float: return delay

func getJumpFallDelay() -> float:
	return (1.8) if movement_type == MOVEMENT_TYPES.JUMP else (fall_time + 1)

func onPreAction() -> void:
	force_action.emit(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.Tile, DestinationTile)))
	if DestinationTile.getHeight() - Card.Tile.getHeight() == 1: movement_type = MOVEMENT_TYPES.JUMP
	elif DestinationTile.getHeight() - Card.Tile.getHeight() <= -1:
		movement_type = MOVEMENT_TYPES.FALL
		var height_diff: int = abs(DestinationTile.getHeight() - Card.Tile.getHeight())
		fall_time = 1 + (height_diff * 0.1)
	elif DestinationTile.isRamp() or Card.Tile.isRamp(): movement_type = MOVEMENT_TYPES.RAMP
	else: movement_type = MOVEMENT_TYPES.REGULAR
	delay = (1.0 if !isJumpFall() else getJumpFallDelay()) if Card.level_visible else 0.0

func onPostAction() -> void:
	var actions: Array = [ OccupyAction.new(Card, DestinationTile, false),\
	StatAction.new(Card, Game.Stats.SPEED, -1, 0, 0, false, false),\
	InVisionResetAction.new(Card)]
	
	var fall_damage: int = DestinationTile.getFallDamage(Card.Tile)
	if fall_damage > 0: actions.append(FallDamageAction.new(Card, DestinationTile))
	
	onPushAction(actions)
