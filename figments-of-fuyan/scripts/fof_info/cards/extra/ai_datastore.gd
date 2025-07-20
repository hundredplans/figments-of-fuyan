class_name AIDatastore extends Resource

const CALL_BASE_COOLDOWN: int = 2
const RECEIVER_BASE_TURNS: int = 4 # How many turns you are the receiver

@export var last_seen_violence: int = -1 # Turns since they last violence, -1 for haven't seen it yet
@export var last_ignore_behaviour_roll: bool
@export var active_archetype: ArchetypeInfo

var DFL: DefaultFightLogic # The last DFL of this unit's ai turn action, used for MOBILE ability checking

var enemies_to_tiles: Dictionary # The enemy card to the tile they were on, if they die it's removed
@export var enemies_to_tiles_public_ids: Dictionary # Card.public_id : Tile.public_id

func setLastSeenViolence(value: bool) -> void:
	last_seen_violence = value
	
func onReset() -> void:
	last_seen_violence = -1
	last_ignore_behaviour_roll = false
	enemies_to_tiles = {}
	
func onCardTurnPassed() -> void:
	if last_seen_violence != -1:
		last_seen_violence += 1
	
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
		
func getActiveArchetype() -> ArchetypeInfo:
	return active_archetype
	
func setActiveArchetype(archetype_info: ArchetypeInfo) -> void:
	active_archetype = archetype_info
	
