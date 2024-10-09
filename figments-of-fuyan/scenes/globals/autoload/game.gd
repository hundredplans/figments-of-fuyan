extends Node

var ActionManagerReference: ActionManagerGD
const SELECTED_MAP_NODE_TRAVEL_SPEED: float = 1
enum Rarities {SCRAP, NEUTRAL, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
enum ShopTypes {CARD, BOON, TOOL, DECK}
enum Phases {NULL, START, HAND, PLAYER, AI, NEUTRAL}
enum SpectateTypes {ALLY, ENEMY, SPAWN}
enum CardPlaces {NULL, HAND, DECK, FIELD, GRAVEYARD}
enum TurnStates {PASSED, INACTIVE, ACTIVE}
enum Stats {ATTACK, HEALTH, SPEED}

var CARD_PLACES_TO_GROUP: Dictionary = {
	CardPlaces.NULL: "",
	CardPlaces.HAND: "HandCardsGD",
	CardPlaces.DECK: "DeckCardsGD",
	CardPlaces.FIELD: "FieldCardsGD",
	CardPlaces.GRAVEYARD: "GraveyardCardsGD"
}


var cube_directions: Array[Vector3i] = [
	Vector3(0, 1, -1),
	Vector3(1, 0, -1),
	Vector3(1, -1, 0),
	Vector3(0, -1, 1),
	Vector3(-1, 0, 1),
	Vector3(-1, 1, 0)
]

var tile_face_directions: Array[Vector3] = [
]

const FALL_DAMAGE_BEGIN_HEIGHT: int = 5
const HEX_SIZE: float = 0.55
const STAT_UPDATE_TIME: float = 0.15

func _ready() -> void:
	var theta: float = PI / 6
	for cube_direction in Game.cube_directions:
		var x: float = HEX_SIZE * (3.0 / 2.0 * cube_direction.x)
		var z: float = HEX_SIZE * (sqrt(3) * (cube_direction.y + cube_direction.x / 2.0))
		tile_face_directions.append(onRotatePosition(Vector3(x, 0, z), theta))

func getRarityString(rarity: Rarities) -> String:
	match rarity:
		Rarities.SCRAP: return "Scrap"
		Rarities.NEUTRAL: return "Neutral"
		Rarities.MINI: return "Mini"
		Rarities.COMMON: return "Common"
		Rarities.RARE: return "Rare"
		Rarities.EXALT: return "Exalt"
		Rarities.MINIBOSS: return "Miniboss"
		Rarities.BOSS: return "Boss"
		Rarities.CHAMPION: return "Champion"
	return "NULL"

func getShopType(shop_type: ShopTypes) -> String:
	match shop_type:
		ShopTypes.CARD: return "Card"
		ShopTypes.BOON: return "Boon"
		ShopTypes.TOOL: return "Tool"
		ShopTypes.DECK: return "Deck alteration"
	return "NULL"

func isBasicRarity(rarity: int) -> bool:
	return rarity > 2 and rarity < 6

func isChampion(rarity: int) -> bool:
	return rarity == 8

#region Tiles / Coords
func getCoordsDistance(coords: Vector4i, _coords: Vector4i) -> int:
	var pos := Vector3(coords.x - _coords.x, coords.y - _coords.y, coords.z - _coords.z)
	return (abs(pos.x) + abs(pos.y) + abs(pos.z)) / 2
	
func onCoordsToPosition(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)

func isCoordsOccupied(coords: Vector4i) -> bool:
	return get_tree().get_nodes_in_group("LevelTilesGD")\
	.any(func(x: TileGD): return x.getCoords() == coords)
	
func getTile(coords: Vector4i) -> TileGD:
	for Tile in get_tree().get_nodes_in_group("LevelTilesGD"):
		if Tile.getCoords() == coords: return Tile
	return null
	
func getAdjacentTiles(Tile: TileGD, distance: int = 1) -> Array:
	return get_tree().get_nodes_in_group("LevelTilesGD").filter(func(x: TileGD): return isAdjacent(Tile, x, distance))
	
func getAdjacentOrCloserTiles(Tile: TileGD, distance: int = 1) -> Array:
	return get_tree().get_nodes_in_group("LevelTilesGD").filter(func(x: TileGD): return Tile != x and isAdjacentOrCloser(Tile, x, distance))
	
func isAdjacent(Tile: TileGD, _Tile: TileGD, distance: int = 1) -> bool:
	var coords: Vector4i = Tile.getCoords()
	var _coords: Vector4i = _Tile.getCoords()
	return abs(coords.x - _coords.x) + abs(coords.y - _coords.y) + abs(coords.z - _coords.z) == distance * 2
	
func isAdjacentOrCloser(Tile: TileGD, _Tile: TileGD, distance: int = 2) -> bool:
	var coords: Vector4i = Tile.getCoords()
	var _coords: Vector4i = _Tile.getCoords()
	return abs(coords.x - _coords.x) + abs(coords.y - _coords.y) + abs(coords.z - _coords.z) <= distance * 2
	
func getRelativeTileRotation(Tile: TileGD, _Tile: TileGD) -> int:
	if Tile == _Tile: return 0
	var direction: Vector3i = _Tile.getCoordsHeightless() - Tile.getCoordsHeightless()
	var distance: int = getCoordsDistance(Tile.getCoords(), _Tile.getCoords())
	
	if distance == 1:
		for i in range(cube_directions.size()):
			if cube_directions[i] == direction: return i
		return 0
		
	var each_tile_distance: Array = []
	for i in range(cube_directions.size()):
		var new_pos: Vector3 = cube_directions[i] + Tile.getCoordsHeightless()
		
		each_tile_distance.append([i, getCoordsDistance(_Tile.getCoords(), Vector4i(new_pos.x, new_pos.y, new_pos.z, 0))])
	each_tile_distance.sort_custom(func(x: Array, y: Array): return x[1] < y[1])
	return each_tile_distance[0][0]
#endregion

#region Units
func getFieldCard(Tile: TileGD) -> CardGD:
	for Card in get_tree().get_nodes_in_group("FieldCardsGD"):
		if Card.Tile == Tile: return Card
	return null

func getAllyUnits(team: int = 0) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.team == team)
	
func getEnemyUnits(team: int = 0) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.team != team)
#endregion

#region Vision
func getTeamVisionDictionary(team: int = 0) -> Dictionary:
	if team < 2: # Neutral units dont have a team vision
		var cards: Array = getAllyUnits(team)
		var team_visible_game_objects: Dictionary = {}
		
		for Card in cards:
			team_visible_game_objects[Card] = null
			team_visible_game_objects[Card.Tile] = null
			for GameObject in Card.getVisibleGameObjects():
				team_visible_game_objects[GameObject] = null
		return team_visible_game_objects
	return {}
	
func getTeamVision(team: int = 0) -> Array:
	return getTeamVisionDictionary(team).keys()
	
func getVisibleFieldCards(team: int = 0) -> Array:
	var cards: Dictionary = {}
	for Card in getAllyUnits(team):
		for _Card in Card.getVisibleFieldCards():
			cards[_Card] = null
	return cards.keys()
#endregion
	
#region Positions
func onRotatePosition(coords: Vector3, theta: float) -> Vector3:
	return Vector3(coords.x * cos(theta) + coords.z * sin(theta), coords.y, -coords.x * sin(theta) + coords.z * cos(theta))
#endregion

#region Phases
func isAdvanceTurn(phase: Phases, team: int) -> bool:
	if phase == Phases.PLAYER and team == 0: return true
	elif phase == Phases.AI and team == 1: return true
	elif phase == Phases.NEUTRAL and team == 2: return true
	return false
#endregion

#region Public ID
var highest_public_id: int
func onIncrementPublicID() -> int:
	highest_public_id += 1
	return highest_public_id
