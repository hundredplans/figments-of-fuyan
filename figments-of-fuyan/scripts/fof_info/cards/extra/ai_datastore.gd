class_name AIDatastore extends Resource

const RECEIVE_CALL_BASE_COOLDOWN: int = 2
const CALL_BASE_COOLDOWN: int = 2
const RECEIVER_BASE_TURNS: int = 4 # How many turns you are the receiver
const ADJACENT_DISTANCE_TO_BREAK_RECEIVING: int = 2 # Double adjacent

@export var last_seen_violence: int = -1 # Turns since they last violence, -1 for haven't seen it yet
@export var receive_call_cooldown: int # Starts at 2 goes down 1 per turn
@export var call_cooldown: int # Starts at 2 goes down 1 per turn
@export var last_ignore_behaviour_roll: bool
@export var is_receiver_turns_remaining: int
var DFL: DefaultFightLogic # The last DFL of this unit's ai turn action, used for MOBILE ability checking

var enemies_to_tiles: Dictionary[CardGD, TileGD] # The enemy card to the tile they were on, if they die it's removed
@export var enemies_to_tiles_public_ids: Dictionary # Card.public_id : Tile.public_id

func setLastSeenViolence(value: bool) -> void:
	last_seen_violence = value

func isReceiver() -> bool:
	return is_receiver_turns_remaining > 0
	
func onCall() -> void:
	call_cooldown = CALL_BASE_COOLDOWN
	
func setIsReceiver(is_receiver: bool, _enemies_to_tiles: Dictionary = {}) -> void:
	enemies_to_tiles = _enemies_to_tiles
	if is_receiver:
		is_receiver_turns_remaining = RECEIVER_BASE_TURNS
		receive_call_cooldown = RECEIVE_CALL_BASE_COOLDOWN
	else:
		is_receiver_turns_remaining = 0
	
func onCanReceive() -> bool:
	return receive_call_cooldown == 0
	
func onReset() -> void:
	last_seen_violence = -1
	receive_call_cooldown = 0
	call_cooldown = 0
	last_ignore_behaviour_roll = false
	is_receiver_turns_remaining = 0
	enemies_to_tiles = {}
	
func onCanCall() -> bool:
	return call_cooldown == 0
	
func onCardTurnPassed() -> void:
	if receive_call_cooldown > 0:
		receive_call_cooldown -= 1
		
	if is_receiver_turns_remaining > 0:
		is_receiver_turns_remaining -= 1
		
	if call_cooldown > 0:
		call_cooldown -= 1
		
	if last_seen_violence != -1:
		last_seen_violence += 1
		
func onCheckDoubleAdjacentAndReceiving(Card: CardGD) -> bool:
	var CardTile: TileGD = Card.getTile()
	if CardTile == null: return false
	
	for Tile in enemies_to_tiles.values():
		if Game.isAdjacentOrCloser(Tile, CardTile, ADJACENT_DISTANCE_TO_BREAK_RECEIVING) and Tile in Card.getVisibleTiles():
			setIsReceiver(false)
			return true
	return false
	
func getEnemyTiles() -> Array:
	return enemies_to_tiles.values()
		
func onSave() -> void:
	enemies_to_tiles_public_ids = {}
	for Card: CardGD in enemies_to_tiles.keys():
		enemies_to_tiles_public_ids[Card.public_id] = enemies_to_tiles[Card].public_id
	
func onLoad() -> void:
	enemies_to_tiles = {}
	for public_id: int in enemies_to_tiles_public_ids.keys():
		var Card: CardGD = Game.onFindPublicIDObject(public_id)
		var Tile: TileGD = Game.onFindPublicIDObject(enemies_to_tiles_public_ids[public_id])
		enemies_to_tiles[Card] = Tile
	
