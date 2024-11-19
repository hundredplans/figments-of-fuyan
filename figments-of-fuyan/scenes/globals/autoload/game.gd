extends Node

var ActionManagerReference: ActionManagerGD
var ADVANCE_PHASES: Array = [Phases.PLAYER, Phases.AI, Phases.NEUTRAL]
const SELECTED_MAP_NODE_TRAVEL_SPEED: float = 1
enum Rarities {SCRAP, NEUTRAL, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
enum ShopTypes {CARD, BOON, TOOL, DECK}
enum Phases {NULL, START, HAND, PLAYER, AI, NEUTRAL}
enum SpectateTypes {ALLY, ENEMY, SPAWN}
enum CardPlaces {NULL, HAND, DECK, FIELD, GRAVEYARD}
enum TurnStates {NULL, PASSED, INACTIVE, ACTIVE}
enum Stats {ATTACK, HEALTH, SPEED, MAX_HEALTH, MAX_SPEED}
enum AscendedExists {BOTH, ONLY_DEFAULT, ONLY_ASCENDED}

var CARD_PLACES_TO_GROUP: Dictionary = {
	CardPlaces.NULL: "Null",
	CardPlaces.HAND: "HandCardsGD",
	CardPlaces.DECK: "DeckCardsGD",
	CardPlaces.FIELD: "FieldCardsGD",
	CardPlaces.GRAVEYARD: "GraveyardCardsGD"
}

var TURN_STATES_TO_STRING: Dictionary = {
	TurnStates.NULL: "Null",
	TurnStates.PASSED: "Passed",
	TurnStates.INACTIVE: "Inactive",
	TurnStates.ACTIVE: "Active"
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

const CARD_REWARD_DEFAULT_AMOUNT: int = 3
const TOOLBELT_SIZE: int = 2

func _ready() -> void:
	var theta: float = PI / 6
	for cube_direction in Game.cube_directions:
		var x: float = HEX_SIZE * (3.0 / 2.0 * cube_direction.x)
		var z: float = HEX_SIZE * (sqrt(3) * (cube_direction.y + cube_direction.x / 2.0))
		tile_face_directions.append(onRotatePosition(Vector3(x, 0, z), theta))

func getStatString(stat: Stats) -> String:
	match stat:
		Stats.ATTACK: return "Attack"
		Stats.HEALTH: return "Health"
		Stats.MAX_HEALTH: return "Max Health"
		Stats.SPEED: return "Speed"
		Stats.MAX_SPEED: "Max Speed"
	return ""

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
	assert(Tile != null and _Tile != null)
	assert(Tile != _Tile)
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
	
func getAllyFieldCard(Tile: TileGD, team: int) -> CardGD:
	var Card: CardGD = getFieldCard(Tile)
	if Card != null and Card.isAlly(team):
		return Card
	return null
	
func getEnemyFieldCard(Tile: TileGD, team: int) -> CardGD:
	var Card: CardGD = getFieldCard(Tile)
	if Card != null and Card.isEnemy(team):
		return Card
	return null

func getAllyUnits(team: int = 0) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.team == team)
	
func getEnemyUnits(team: int = 0) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.team != team)
	
func getBaseCard(id: int, Tile: TileGD, team: int, tile_rotation: int, ascended: bool = false) -> SavedDataCard:
	return Helper.getFofInfoID(CardInfo, id).saved_data.new(id, true, 0, Tile.getCoords(), tile_rotation, VisionDatastore.new(), team, ascended)

func getNewFieldCard(id: int, Tile: TileGD, team: int, tile_rotation: int, ascended: bool = false) -> CardGD:
	var level: LevelGD = get_tree().get_nodes_in_group("LevelsGD")[0]
	return SavedData.onLoadModel(getBaseCard(id, Tile, team, tile_rotation, ascended), level)

func getUnitTiles() -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").map(func(x: CardGD): return x.Tile)
#endregion

#region Vision
func inVisionCards(card_coords: Vector4i) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD):
		return x.getCoords() != card_coords and getCoordsDistance(x.getCoords(), card_coords) <= x.getVisionRange())

func getTeamVisionDictionary(team: int = 0) -> Dictionary:
	if team < 2: # Neutral units dont have a team vision
		var cards: Array = getAllyUnits(team)
		var team_visible_game_objects: Dictionary = {}
		
		for Card in cards:
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

# Default coords, rotates counter clockwise which is default for tile rotation
func onRotateCoordsCC(tile_rotation: int, coords := Vector4i(0, 1, -1, 0)) -> Vector4i:
	for __ in range(tile_rotation):
		coords = Vector4i(-coords.z, -coords.x, -coords.y, coords.w)
	return coords

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
	
func onFindPublicIDObject(public_id: int) -> FofGD:
	for FofObject in get_tree().get_nodes_in_group("FofGD"):
		if FofObject.public_id == public_id: return FofObject
	return null
#endregion

#region Enemy Turns
func getNextInactiveCard(team: int) -> CardGD:
	var cards: Array = getAllyUnits(team).filter(func(x: CardGD): return x.turn_state == Game.TurnStates.INACTIVE)
	cards.sort_custom(onSortByMaxSpeed)
	return cards[0] if !cards.is_empty() else null
	
func onSortByMaxSpeed(Card: CardGD, _Card: CardGD) -> bool:
	if Card.max_speed == _Card.max_speed:
		return Card.public_id < _Card.public_id
	return Card.max_speed < _Card.max_speed
#endregion

#region Movement Range
func getsetMovementRange(Card: CardGD) -> Array:
	get_tree().call_group("FieldCardsGD", "setEnemyInMovementRange", false)
	get_tree().call_group("LevelTilesGD", "setMovementPath", null)
	
	var CenterTile: TileGD = Card.Tile
	var speed: int = min(Card.getMovementSpeed(), 4)
	var tiles: Array = Game.getAdjacentOrCloserTiles(Card.Tile, speed) # Gather all tiles
	
	var all_cards_tiles: Array = get_tree().get_nodes_in_group("FieldCardsGD").map(func(x: CardGD): return x.Tile)
	
	tiles = tiles.filter(func(x: TileGD): return !x.isSolid() and x not in all_cards_tiles) # Check for solidity
	for Tile in tiles:
		var astar := AStar3D.new()
		# Limits tiles to those in movement range
		var add_to_astar_tiles: Array = tiles.filter(func(x: TileGD): return Game.getCoordsDistance(Tile.getCoords(), x.getCoords()) <= speed)
		add_to_astar_tiles.append(CenterTile)
		for _Tile in add_to_astar_tiles: astar.add_point(_Tile.get_instance_id(), _Tile.getCoordsHeightless())
		
		for StartTile in add_to_astar_tiles:
			for EndTile in add_to_astar_tiles.filter(func(x: TileGD): return Game.isAdjacent(x, StartTile)):
				var height_diff: int = EndTile.getHeight() - StartTile.getHeight()
				if StartTile.isRamp():
					if StartTile.isValidRampRelation(EndTile):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif EndTile.isRamp():
					if EndTile.isValidRampRelation(StartTile):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif height_diff <= 1:
					astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
		var valid_path: bool = false
		var point_path: Array = []
		var movement_path: Array = []
		
		while(!valid_path):
			point_path = astar.get_id_path(CenterTile.get_instance_id(), Tile.get_instance_id())
			if point_path.is_empty(): break
			if point_path.size() > speed + 1:
				astar.disconnect_points(point_path[point_path.size() - 1], point_path[point_path.size() - 2])
				continue
			
			movement_path = point_path.map(func(x: int): return instance_from_id(x))
			if movement_path.size() > speed + 2:
				astar.disconnect_points(point_path[point_path.size() - 1], point_path[point_path.size() - 2])
				continue
			if !onSurviveFallDamage(Card, movement_path, point_path, astar): continue
			
			
			valid_path = true
			
		Tile.setMovementPath(MovementPathGD.new(movement_path) if valid_path else null)
	
	var available_tiles: Array = tiles.filter(func(x: TileGD): return x.getMovementPathDisplay())
	available_tiles.append(CenterTile)
	
	var attackables: Dictionary = Card.getAttackablesInRange()
	for GameObject in attackables:
		var Tile: TileGD = attackables[GameObject]
		var coords: Vector4i = Tile.getCoords()
		
		var tiles_in_range: Array = available_tiles.filter(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), coords) <= Card.getAttackRange())
		if tiles_in_range.is_empty(): continue
		
		var AttackFromTile: TileGD
		var attack_from_path: Array = []
		if CenterTile not in tiles_in_range:
			tiles_in_range.sort_custom(func(x: TileGD, y: TileGD): return x.getMovementPathSize() < y.getMovementPathSize())
			AttackFromTile = tiles_in_range[0]
			attack_from_path = AttackFromTile.movement_path.tiles.duplicate()
		else: # Closest tile is always the center tile as it's distance is 0, has to have unique logic as it doesn't generate paths
			AttackFromTile = CenterTile
			attack_from_path = [CenterTile]
		
		available_tiles.append(Tile)
		attack_from_path.append(Tile)
		
		Tile.setMovementPath(MovementPathGD.new(attack_from_path))
		if GameObject is CardGD:
			GameObject.setEnemyInMovementRange(true)
	return available_tiles
	
func onSurviveFallDamage(Card: CardGD, movement_path: Array, point_path: Array, astar: AStar3D) -> bool:
	Card.temp_fall_damage = 0
	for i in range(1, movement_path.size()):
		var fall_damage: int = movement_path[i].getFallDamage(movement_path[i - 1])
		if fall_damage > 0:
			var survive_fall_damage: bool = Card.isCardSurviveFallDamage(fall_damage)
			if !survive_fall_damage and i != movement_path.size() - 1:
				astar.disconnect_points(point_path[i - 1], point_path[i])
				return false
	return true
#endregion

#region Map Effect Generator
func onCreateGainShillings(shilling_amount: int, parent: Node) -> MapEffectGD:
	return SavedData.onLoadModel(SavedDataMapEffectGainShillings.new(2, true, 0, shilling_amount), parent)

func onGainFofObject(fof_object: FofGD) -> void:
	pass
#endregion

#region Tooltips
const TOOLTIP_PACKED_PATH: String = "res://scenes/common/tooltip/tooltip.tscn"
const TOOLTIP_DELAY: float = 0.3
var Tooltip: Control
func onMouseInUITooltip(state: bool, item: FofGD = null, parent: Control = null, offset := Vector2.ZERO) -> void:
	if state and Tooltip == null:
		await get_tree().create_timer(TOOLTIP_DELAY)
		if !(state and Tooltip == null): return
		
		Tooltip = load(TOOLTIP_PACKED_PATH).instantiate()
		parent.add_child(Tooltip)
		Tooltip.setInfo(item)
		Tooltip.global_position = get_viewport().get_mouse_position() + offset
		
	elif !state and Tooltip != null:
		Tooltip.queue_free()
#endregion
