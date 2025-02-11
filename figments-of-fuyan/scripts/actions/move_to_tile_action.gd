class_name MoveToTileAction extends Action

enum MOVEMENT_TYPES {REGULAR, RAMP, JUMP, FALL}
var Card: CardGD
var DestinationTile: TileGD
var movement_type: MOVEMENT_TYPES

const JUMP_FALL_TIME_OFFSET: float = 0.5
var fall_time: float

func isJumpFall() -> bool:
	return movement_type == MOVEMENT_TYPES.JUMP or movement_type == MOVEMENT_TYPES.FALL

func _init(_Card: CardGD = null, _DestinationTile: TileGD = null) -> void:
	super()
	Card = _Card
	DestinationTile = _DestinationTile

func setMovementTypeDelay() -> void:
	fall_time = 1
	if DestinationTile.isRamp() or Card.Tile.isRamp(): movement_type = MOVEMENT_TYPES.RAMP
	elif DestinationTile.getHeight() - Card.Tile.getHeight() == 1: movement_type = MOVEMENT_TYPES.JUMP; fall_time += JUMP_FALL_TIME_OFFSET
	elif DestinationTile.getHeight() - Card.Tile.getHeight() <= -1:
		movement_type = MOVEMENT_TYPES.FALL
		var height_diff: int = abs(DestinationTile.getHeight() - Card.Tile.getHeight())
		fall_time += (height_diff * 0.2)
	else: movement_type = MOVEMENT_TYPES.REGULAR
	
	setActionDelay(getJumpDelay() if Card.isLevelVisible() else 0.0)

func getJumpDelay() -> float:
	return 1.0 if !isJumpFall() else fall_time

func setActionDelay(delay: float) -> void:
	super(delay)
	
func onPreAction() -> void:
	onCheckFail()
	if failed: return
	
	setMovementTypeDelay()
	onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.Tile, DestinationTile)))
	Card.onMoveToTile(self, getDelay())
	
func onCheckFail() -> void:
	if DestinationTile.isOccupied():
		onFailAction()

func onPostAction() -> void:
	var actions: Array = [OccupyAction.new(Card, DestinationTile, false),\
	StatAction.new(StatInfo.new(Card, Game.Stats.SPEED, -1, 0, false, false, true))]
	
	var fall_damage: int = DestinationTile.getFallDamage(Card.Tile)
	if fall_damage > 0: actions.append(FallDamageAction.new(Card, DestinationTile))
	
	onPushAction(actions)
