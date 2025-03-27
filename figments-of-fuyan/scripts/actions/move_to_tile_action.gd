class_name MoveToTileAction extends Action

enum MOVEMENT_TYPES {REGULAR, RAMP, JUMP, FALL}
var Card: CardGD

var OriginalTile: TileGD
var DestinationTile: TileGD
var movement_type: MOVEMENT_TYPES

const JUMP_FALL_TIME_OFFSET: float = 0.5
var fall_time: float
var destroy_on_occupy: bool

func isJumpFall() -> bool:
	return movement_type == MOVEMENT_TYPES.JUMP or movement_type == MOVEMENT_TYPES.FALL

func _init(_Card: CardGD = null, _DestinationTile: TileGD = null, _destroy_on_occupy: bool = false) -> void:
	super()
	Card = _Card
	DestinationTile = _DestinationTile
	destroy_on_occupy = _destroy_on_occupy

func setMovementTypeDelay() -> void:
	fall_time = 1
	if DestinationTile.isRamp() or Card.Tile.isRamp(): movement_type = MOVEMENT_TYPES.RAMP
	elif DestinationTile.getHeight() - Card.Tile.getHeight() >= 1: movement_type = MOVEMENT_TYPES.JUMP; fall_time += JUMP_FALL_TIME_OFFSET
	elif DestinationTile.getHeight() - Card.Tile.getHeight() <= -1:
		movement_type = MOVEMENT_TYPES.FALL
		var height_diff: int = abs(DestinationTile.getHeight() - Card.Tile.getHeight())
		fall_time += (height_diff * 0.25)
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
	
	if !Card.is_knockback:
		onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.Tile, DestinationTile)))
		
	OriginalTile = Card.Tile
	Card.onMoveToTile(self, getDelay())
	
func onCheckFail() -> void:
	if DestinationTile.isOccupied() and !destroy_on_occupy:
		onFailAction()

func onPostAction() -> void:
	var actions: Array = [OccupyAction.new(Card, DestinationTile, false),\
	StatAction.new(StatInfo.new(Card, Game.Stats.SPEED, -1, 0, false, false, true))]
	
	if destroy_on_occupy:
		var DestroyedCard: CardGD = Game.getFieldCard(DestinationTile)
		if DestroyedCard != null:
			actions.push_front(DestroyAction.new(DestroyedCard))
	
	var fall_damage: int = DestinationTile.getFallDamage(Card.Tile)
	if fall_damage > 0: actions.append(FallDamageAction.new(Card, Card.Tile, DestinationTile))
	
	onPushAction(actions)
