extends Node

signal mouse_in_ui
var is_mouse_in_ui: bool
var save_file: SaveFileGD
var area: AreaGD

var brain: bool # AI Brain

var ActionManagerReference: ActionManagerGD
var ADVANCE_PHASES: Array = [Phases.PLAYER, Phases.AI, Phases.NEUTRAL]

const SELECTED_MAP_NODE_TRAVEL_SPEED: float = 1
enum Rarities {SCRAP, NEUTRAL, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
enum ShopTypes {CARD, BOON, TOOL, DECK}
enum Phases {NULL, START, HAND, PLAYER, AI, NEUTRAL}
enum SpectateTypes {ALLY, ENEMY, SPAWN}
enum CardPlaces {NULL, HAND, DECK, FIELD, GRAVEYARD, STASH}
enum TurnStates {NULL, PASSED, INACTIVE, ACTIVE}
enum Stats {ATTACK, HEALTH, SPEED, MAX_HEALTH, MAX_SPEED, ENERGY}
enum AscendedExists {BOTH, ONLY_DEFAULT, ONLY_ASCENDED}
enum Archetypes {NULL, ADVENTURER, BRUTE, DOCILE, ERRATIC, HOSTILE, REINFORCER, SCOUT, SUPPORT, TACTICIAN, WARDEN, RECEIVER, MERCENARY}
enum DamageTypes {ATTACK, FALL_DAMAGE, OTHER}
enum FightTypes {NULL, REGULAR, ELITE, MINIBOSS, BOSS}
enum TileIntents {NULL, RED, PURPLE, GREEN, DARK_RED, LIGHT_RED, YELLOW, LIGHTER_RED}

var CARD_PLACES_TO_GROUP: Dictionary = {
	CardPlaces.NULL: "Null",
	CardPlaces.HAND: "HandCardsGD",
	CardPlaces.DECK: "DeckCardsGD",
	CardPlaces.FIELD: "FieldCardsGD",
	CardPlaces.GRAVEYARD: "GraveyardCardsGD",
	CardPlaces.STASH: "StashCardsGD",
}

var TURN_STATES_TO_STRING: Dictionary = {
	TurnStates.NULL: "Null",
	TurnStates.PASSED: "Passed",
	TurnStates.INACTIVE: "Inactive",
	TurnStates.ACTIVE: "Active"
}


var cube_directions: Array[Vector3i] = [
	Vector3i(0, 1, -1),
	Vector3i(1, 0, -1),
	Vector3i(1, -1, 0),
	Vector3i(0, -1, 1),
	Vector3i(-1, 0, 1),
	Vector3i(-1, 1, 0)
]

var tile_face_directions: Array[Vector3] = [
]

const CARD_UI_SIZE := Vector2(264, 400)

const FALL_DAMAGE_BEGIN_HEIGHT: int = 5
const HEX_SIZE: float = 0.55
const STAT_UPDATE_TIME: float = 0.15
const ATTACK_DELAY: float = 1.25

const CARD_REWARD_DEFAULT_AMOUNT: int = 3
const ASCENDED_COLOR := Color(0.937, 0.835, 0.318)
const ASCENDED_OUTLINE_COLOR := Color(0.512, 0.447, 0.099)

const FADE_TIME: float = 0.25

func _ready() -> void:
	tile_face_directions = [Vector3((sqrt(3.0) / 4.0), 0, (3.0 / 4.0)), Vector3((sqrt(3.0) / 2.0), 0, 0),
	Vector3(-(sqrt(3.0) / 4.0), 0, (3.0 / 4.0)), Vector3((sqrt(3.0) / 4.0), 0, -(3.0 / 4.0)),
	Vector3(-(sqrt(3.0) / 4.0), 0, -(3.0 / 4.0)), Vector3(-(sqrt(3.0) / 2.0), 0, 0)]
	#for cube_direction in Game.cube_directions:
		#var x: float = HEX_SIZE * (3.0 / 2.0 * cube_direction.x)
		#var z: float = HEX_SIZE * (sqrt(3) * (cube_direction.y + cube_direction.x / 2.0))
		#tile_face_directions.append(Vector3(x, 0, z))

func getRarityThemeVariation(rarity: Rarities, ascended: bool = false) -> String:
	var theme_variation: String
	match rarity:
		Game.Rarities.SCRAP, Game.Rarities.MINI: theme_variation = "GreyPanelContainer"
		Game.Rarities.NEUTRAL: theme_variation = "DarkBrownPanelContainer"
		Game.Rarities.COMMON: theme_variation = "BeigePanelContainer"
		Game.Rarities.RARE: theme_variation = "TealPanelContainer"
		Game.Rarities.EXALT: theme_variation = "WhitePanelContainer"
		Game.Rarities.MINIBOSS: theme_variation = "PurplePanelContainer"
		Game.Rarities.BOSS: theme_variation = "RedPanelContainer"
		Game.Rarities.CHAMPION: theme_variation = "BluePanelContainer"
		_: theme_variation = "YellowPanelContainer"
	if ascended: theme_variation += "Ascended"
	return theme_variation

func getStatString(stat: Stats) -> String:
	match stat:
		Stats.ATTACK: return "Attack"
		Stats.HEALTH: return "Health"
		Stats.MAX_HEALTH: return "Max Health"
		Stats.SPEED: return "Speed"
		Stats.MAX_SPEED: return "Max Speed"
		Stats.ENERGY: return "Energy"
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
	
func getRarityColor(rarity: Rarities) -> Color:
	match rarity:
		Rarities.SCRAP: return Color(0.627, 0.627, 0.627)
		Rarities.NEUTRAL: return Color(0.498, 0.2, 0)
		Rarities.COMMON: return Color(0.81, 0.62, 0.5)
		Rarities.RARE: return Color(0, 0.77, 0.56)
		Rarities.EXALT: return Color(0.859, 0.859, 0.859)
		Rarities.MINIBOSS: return Color(0.475, 0.161, 0.62)
		Rarities.BOSS: return Color(0.647, 0.188, 0.188)
		Rarities.CHAMPION: return Color(0.086, 0.549, 0.878)
	return Color(1, 1, 1)

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
	
func getAdjacentOrCloserCoords(coord: Vector4i, distance: int = 1) -> Array:
	var coords: Array = []
	for x: int in range(-distance, (distance + 1)):
		for y: int in range(max(-distance, -x - distance), min(distance, -x + distance) + 1):
			coords.append(Vector4i(x, y, -x-y, 0) + coord)
	coords.erase(coord)
	return coords
	
func getAdjacentCoords(coord: Vector4i, distance: int = 1) -> Array:
	return getAdjacentOrCloserCoords(coord, distance).filter(func(x: Vector4i): return Game.getCoordsDistance(x, coord) == distance)
	
func getAdjacentTiles(Tile: TileGD, distance: int = 1) -> Array:
	return get_tree().get_nodes_in_group("LevelTilesGD").filter(func(x: TileGD): return isAdjacent(Tile, x, distance))
	
func getAdjacentOrCloserTiles(Tile: TileGD, distance: int = 1) -> Array: # Excludes given tile
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
	if Tile == null or _Tile == null: return -1
	return getRelativeTileRotationCoords(Tile.getCoords(), _Tile.getCoords())
	
func getRelativeTileRotationCoords(coords: Vector4i, _coords: Vector4i) -> int:
	if coords == _coords: return -1
	var d: Vector4i = _coords - coords
	var direction := Vector3i(d.x, d.y, d.z)
	var distance: int = getCoordsDistance(coords, _coords)
	
	if distance == 1:
		for i in range(cube_directions.size()):
			if cube_directions[i] == direction: return i
		return 0
		
	var each_tile_distance: Array = []
	for i in range(cube_directions.size()):
		var cube_pos: Vector3i = cube_directions[i]
		var new_pos := Vector4i(cube_pos.x, cube_pos.y, cube_pos.z, 0) + coords
		new_pos.w = 0
		each_tile_distance.append([i, getCoordsDistance(_coords, new_pos)])
	each_tile_distance.sort_custom(func(x: Array, y: Array): return x[1] < y[1])
	return each_tile_distance[0][0]
	
func getFanTiles(coords: Vector4i, distance: int, tile_rotation: int) -> Array:
	return getFanCoords(coords, distance, tile_rotation).map(func(x: Vector4i): return getTile(x))
	
func getFanCoords(coords: Vector4i, distance: int, tile_rotation: int = 0) -> Array:
	var adjacent_coords: Array = getAdjacentOrCloserCoords(coords, distance)
	var last_diagonal_coords: Vector4i = (Game.getCubeDirectionExtra(tile_rotation) * distance) + coords
	adjacent_coords = adjacent_coords.filter(func(x: Vector4i): return Game.getCoordsDistance(x, last_diagonal_coords) <= distance)
	adjacent_coords.erase(coords)
	return adjacent_coords
	
func getInversePyramidCoords(coords: Vector4i, distance: int, first_tile_rotation: int, second_tile_rotation: int, offset: int) -> Array: # Get two tile rotations next to each other
	var inverse_pyramid_coords: Array = []
	var first_cube_direction: Vector4i = getCubeDirectionExtra(first_tile_rotation)
	var second_cube_direction: Vector4i = getCubeDirectionExtra(second_tile_rotation)
	
	var adjacent_numbers: Array = [posmod(first_tile_rotation + offset, 6), posmod(second_tile_rotation + offset, 6)]
	var direction_tile_rotation: int = adjacent_numbers.filter(func(x: int): return x != first_tile_rotation and x != second_tile_rotation)[0]
	 
	
	for i: int in range(1, distance + 1):
		var first_coords: Vector4i = coords + (first_cube_direction * i)
		var second_coords: Vector4i = coords + (second_cube_direction * i)
		
		inverse_pyramid_coords.append(first_coords)
		inverse_pyramid_coords.append(second_coords)
		inverse_pyramid_coords += getStraightLineCoords(first_coords, i - 1, direction_tile_rotation)
	return inverse_pyramid_coords
	
func getStraightLineCoords(coords: Vector4i, distance: int, tile_rotation: int) -> Array:
	var straight_line_coords: Array = []
	var cube_direction: Vector4i = Game.getCubeDirectionExtra(tile_rotation)
	
	for i: int in range(1, distance + 1):
		straight_line_coords.append((cube_direction * i) + coords)
	
	return straight_line_coords
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

func getNewFieldCard(id: int, Tile: TileGD, team: int, tile_rotation: int, ascended: bool = false, awakened_in_combat: bool = false) -> CardGD:
	var level: LevelGD = Game.getLevel()
	var Card: CardGD = SavedData.onLoadModel(getBaseCard(id, Tile, team, tile_rotation, ascended), level)
	if awakened_in_combat: Card.setAwakenedInCombat(awakened_in_combat)
	return Card

func getUnitTiles() -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").map(func(x: CardGD): return x.Tile)
#endregion

#region Vision
func inVisionRangeCardsCoords(coords: Vector4i, include_self: bool = false) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD):
		return (x.getCoords() != coords or include_self) and getCoordsDistance(x.getCoords(), coords) <= x.getVisionRange())

func inVisionRangeCards(Tile: TileGD, include_self: bool = false) -> Array:
	return inVisionRangeCardsCoords(Tile.getCoords(), include_self)

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
	
func onCreateRevealedDatastore(_owner: FofGD, team: int = -1) -> RevealedDatastore:
	var revealed_datastore := RevealedDatastore.new()
	var revealed_id: int = randi()
	revealed_datastore.setInfo(_owner, revealed_id, team)
	return revealed_datastore
#endregion
	
#region Positions
func onRotatePosition(coords: Vector3, theta: float) -> Vector3:
	return Vector3(coords.x * cos(theta) + coords.z * sin(theta), coords.y, -coords.x * sin(theta) + coords.z * cos(theta))

# Default coords, rotates counter clockwise which is default for tile rotation
func onRotateCoordsCC(tile_rotation: int, coords := Vector4i(0, 1, -1, 0)) -> Vector4i:
	for __ in range(tile_rotation):
		coords = Vector4i(-coords.z, -coords.x, -coords.y, coords.w)
	return coords

func onRotateCoordsClockwise(tile_rotation: int, coords := Vector4i(0, 1, -1, 0)) -> Vector4i:
	for __ in range(tile_rotation):
		coords = Vector4i(-coords.y, -coords.z, -coords.x, coords.w)
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
var public_id_objects: Dictionary[int, FofGD] = {}
var highest_public_id: int
func onIncrementPublicID() -> int:
	highest_public_id += 1
	return highest_public_id
	
func setPublicID(fof: FofGD) -> void:
	public_id_objects[fof.public_id] = fof
	
func onFindPublicIDObject(public_id: int) -> FofGD:
	if public_id_objects.has(public_id):
		return public_id_objects[public_id]
	return null
#endregion

#region Enemy Turns
func getNextInactiveCard(team: int) -> CardGD:
	var cards: Array = getAllyUnits(team).filter(func(x: CardGD): return x.turn_state == Game.TurnStates.INACTIVE)
	var level := getLevel()
	return level.getNextAIUnit(cards, team)
#endregion

#region Tooltips
const TOOLTIP_PACKED_PATH: String = "res://scenes/common/tooltip/tooltip.tscn"
var Tooltip: Control
func onMouseInUITooltip(state: bool, item: Variant = null, parent: Control = null, create_inner_tooltips: bool = true, offset := Vector2(30, 0)) -> void:
	if Tooltip != null: Tooltip.queue_free()
	if state:
		if item is Array and item.is_empty(): return
		if item is not Array: item = [item]
		Tooltip = load(TOOLTIP_PACKED_PATH).instantiate()
		parent.add_child(Tooltip)
		Tooltip.setInfo(item, offset, create_inner_tooltips)
		Tooltip.setPosition()
		
func onEmptyTooltip(state: bool, child: Control = null, parent: Control = null) -> Control:
	if Tooltip != null: Tooltip.queue_free()
	if state:
		Tooltip = Control.new()
		Tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		Tooltip.size = Vector2.ZERO
		parent.add_child(Tooltip)
		Tooltip.add_child(child)
		return Tooltip
	return null
#endregion

#region Cards
func isIDInDeck(id: int) -> bool:
	return get_tree().get_nodes_in_group("DeckCardsGD").any(func(x: CardGD): return x.info.id == id)

func getDeckSize() -> int:
	return get_tree().get_nodes_in_group("DeckCardsGD").size()
	
func getDeckCards() -> Array:
	return get_tree().get_nodes_in_group("DeckCardsGD")
	
func getDeckCardsNoChampion() -> Array:
	return getDeckCards().filter(func(x: CardGD): return x.info.rarity != Rarities.CHAMPION)
	
func getBaseCard(id: int, Tile: TileGD, team: int, tile_rotation: int, ascended: bool = false) -> SavedDataCard:
	var card_info: CardInfo = Helper.getFofInfoID(CardInfo, id)
	var card_data: SavedDataCard = card_info.saved_data.new(id, true, 0, Tile.getCoords(), tile_rotation, VisionDatastoreCard.new(), team, ascended)
	setCardDataFromInfo(card_data, card_info)
	return card_data
	
func getRandomNonChampionCard() -> CardGD:
	return get_tree().get_nodes_in_group("DeckCardsGD").filter(func(x: CardGD): return x.info.rarity != Rarities.CHAMPION).pick_random()
	
func setCardDataFromInfo(card_data: SavedDataCard, card_info: CardInfo) -> SavedDataCard:
	card_data.energy = card_info.energy + (card_info.plus_energy if card_data.ascended else 0)
	card_data.max_speed = card_info.speed + (card_info.plus_speed if card_data.ascended else 0)
	card_data.max_health = card_info.health + (card_info.plus_health if card_data.ascended else 0)
	
	card_data.attack = card_info.attack + (card_info.plus_attack if card_data.ascended else 0)
	card_data.health = card_data.max_health
	card_data.speed = card_data.max_speed
	return card_data
	
const REMOVE_CARD_ANIMATION_TIME: float = 2
const REMOVE_CARD_ANIMATION_OFFSET: float = 0.5
const TOTAL_SPIN_DEGREES: int = 360
func onRemoveCardWithAnimation(Card: CardGD, parent: Control, action_user: FofGD) -> void:
	var CardUI: Control = Card.onCreateCardUI(parent, false)
	CardUI.global_position = get_viewport().get_mouse_position() - (CardUI.size / 2)
	CardUI.setDisabled(true)
	
	var rotate_tween := create_tween()
	rotate_tween.tween_property(CardUI, "rotation_degrees", TOTAL_SPIN_DEGREES, REMOVE_CARD_ANIMATION_TIME)
	
	var scale_tween := create_tween()
	scale_tween.tween_property(CardUI, "scale", Vector2(0.01, 0.01), REMOVE_CARD_ANIMATION_TIME)
	await get_tree().create_timer(REMOVE_CARD_ANIMATION_TIME + REMOVE_CARD_ANIMATION_OFFSET).timeout
	
	action_user.onPushAction(RemoveFromDeckAction.new(Card, true))
	
func onCreateBaseCard(id: int, ascended: bool = false, tool_data: SavedDataTool = null) -> SavedDataCard:
	var card_data := SavedDataCard.new(id, true)
	setCardDataFromInfo(card_data, Helper.getFofInfoID(CardInfo, id))
	card_data.tool_data = tool_data
	card_data.ascended = ascended
	return card_data
#endregion

#region Boons
func isBoonAvailable(id: int, extra_ids: Array = []) -> bool:
	var boons: Array = save_file.boons 
	return id not in extra_ids and (boons.is_empty() or !boons.any(func(x: BoonGD): return x.info.id == id and x.ascended))
	
func isBoonAvailableUnascended(id: int) -> bool: # Does an unascended version of the Boon exist in the player's deck
	var boons: Array = save_file.boons 
	return boons.any(func(x: BoonGD): return x.info.id == id and !x.ascended)
	
func isBoonInGame(id: int) -> bool:
	return save_file.boons.any(func(x: BoonGD): return x.info.id == id)
	
func getAvailableBoons() -> Array:
	var all_boons: Array = Helper.getFofInfoArray(BoonInfo)
	var used_boon_ids: Array = Game.getSaveFile().getBoons()\
		.filter(func(x: BoonGD): return x.ascended)\
		.map(func(x: BoonGD): return x.info.id)
	return all_boons.filter(func(x: BoonInfo): return x.id not in used_boon_ids)
#endregion

#region Tools
func playerHasTool(id: int) -> bool: # Player has a regular or ascended tool, in tool belt or in deck
	return get_tree().get_nodes_in_group("DeckCardsGD").any(func(x: CardGD): return x.Tool != null and x.Tool.info.id == id) \
		or save_file.tool_belt.any(func(x: ToolGD): return x.info.id == id)
#endregion

#region Animation
const FLY_UI_ANIMATION_SPEED: float = 0.8
const FLY_UI_DISSAPEAR_SPEED: float = 1
func onFlyToUI(DisplayedUI: Control, To: Control) -> void:
	var tween := create_tween()
	tween.tween_property(DisplayedUI, "global_position", To.global_position, FLY_UI_ANIMATION_SPEED)
	
	var scale_tween := create_tween()
	scale_tween.tween_property(DisplayedUI, "scale", Vector2(0.01, 0.01), FLY_UI_ANIMATION_SPEED)
	
	var rotate_tween := create_tween()
	rotate_tween.tween_property(DisplayedUI, "rotation_degrees", 360, FLY_UI_ANIMATION_SPEED)
	
	await get_tree().create_timer(FLY_UI_DISSAPEAR_SPEED).timeout
	if DisplayedUI != null: DisplayedUI.queue_free()
#endregion

#region Scene Creator
const TOOL_PICKED_UP_UI_SCENE_PATH: String = "res://scenes/game/tools/extra/tool_picked_up_ui.tscn"
func onCreateToolPickedUpUI(Tool: ToolGD, remove_dispose: bool, parent: Control) -> Control:
	var ToolPickedUpUI: Control = load(TOOL_PICKED_UP_UI_SCENE_PATH).instantiate()
	parent.add_child(ToolPickedUpUI)
	ToolPickedUpUI.setInfo(Tool, save_file, remove_dispose)
	return ToolPickedUpUI
	
const PICK_TOOL_UI_SCENE_PATH: String = "res://scenes/game/tools/extra/pick_tool_ui.tscn"
func onCreatePickToolUI(tool_info: ToolInfo, parent: Control) -> Control:
	var PickToolUI: Control = load(PICK_TOOL_UI_SCENE_PATH).instantiate()
	parent.add_child(PickToolUI)
	PickToolUI.setInfo(tool_info, save_file)
	return PickToolUI
	
const DECK_SCREEN_PATH: String = "res://scenes/game/levels/ui/deck_screen.tscn"
func onCreateDeckScreen(parent: Control, selectable: bool, max_select_amount: int = 1, filter_callable := Callable(), valid_selection := Callable()) -> Control:
	var DeckScreen: Control = load(DECK_SCREEN_PATH).instantiate()
	parent.add_child(DeckScreen)
	DeckScreen.setInfo(selectable, max_select_amount, valid_selection)
	DeckScreen.onDisableCards(filter_callable)
	return DeckScreen
	
const REWARDS_SCREEN_PATH: String = "res://scenes/common/rewards_screen/rewards_screen.tscn"
func onCreateRewardsScreen(rewards: Rewards, parent: Control, level_type: FightTypes) -> Control:
	var RewardsUI: Control = load(REWARDS_SCREEN_PATH).instantiate()
	parent.add_child(RewardsUI)
	RewardsUI.setInfo(rewards, level_type)
	return RewardsUI
	
const CHOOSE_REWARDS_UI_PATH: String = "res://scenes/common/rewards_ui/choose_rewards_ui.tscn"
func onCreateChooseRewardsUIScreen(reward: Reward, parent: Control) -> Control:
	var ChooseRewardsUI: Control = load(CHOOSE_REWARDS_UI_PATH).instantiate()
	parent.add_child(ChooseRewardsUI)
	ChooseRewardsUI.setInfo(reward)
	return ChooseRewardsUI
	
const PAUSE_MENU_PATH: String = "res://scenes/menus/pause_menu/pause_menu.tscn"
func onCreatePauseMenu(parent: Control) -> Control:
	var PauseMenu: Control = load(PAUSE_MENU_PATH).instantiate()
	parent.add_child(PauseMenu)
	return PauseMenu
	
const STASH_SCREEN_PATH: String = "res://scenes/game/map/stash_screen.tscn"
func onCreateStashScreen(parent: Control, ActiveToolIcon: Control = null) -> Control:
	var StashScreen: Control = load(STASH_SCREEN_PATH).instantiate()
	parent.add_child(StashScreen)
	StashScreen.setInfo()
	if ActiveToolIcon != null:
		StashScreen.setActiveToolIcon(ActiveToolIcon)
	
	return StashScreen

const CHAMPION_UPGRADE_UI_PATH: String = "res://scenes/common/champion_upgrade_ui/champion_upgrade_ui.tscn"
func onCreateChampionUpgradeUI(parent: Control, old_deck_limit: int, old_energy_limit: int, old_max_energy: int) -> Control:
	var ChampionUpgradeUI: Control = load(CHAMPION_UPGRADE_UI_PATH).instantiate()
	parent.add_child(ChampionUpgradeUI)
	ChampionUpgradeUI.setInfo(old_deck_limit, old_energy_limit, old_max_energy)
	return ChampionUpgradeUI
#endregion

#region Champion
func onAddDivinusBoonAscenscionOdds(odds: float) -> float:
	if !isDivinus(): return odds
	return odds + 2.5
	
func getHolyTravelledAmount() -> int:
	if isDivinus():
		return save_file.getChampionCard().holy_travelled_amount
	return 0
	
func onIncrementHolyTravelledAmount() -> void:
	if isDivinus(): save_file.getChampionCard().holy_travelled_amount += 1
	
func isDivinus() -> bool:
	return save_file.getChampionCard().info.id == 2
#endregion

#region Getters
func getLevel() -> LevelGD:
	var levels: Array = Game.get_tree().get_nodes_in_group("LevelsGD")
	return null if levels.is_empty() else levels[0]
	
func getArea() -> AreaGD:
	return area

func getSaveFile() -> SaveFileGD:
	return save_file

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
func isMouseInUI() -> bool:
	return is_mouse_in_ui
	
func getChampionLevel() -> int:
	return 0 if save_file == null else save_file.getChampionLevel()
	
func isLevel() -> bool:
	return Game.getLevel() != null
#endregion

#region Coords To Tile
var coords_to_tile: Dictionary = {}
func getTile(_coords: Vector4i) -> TileGD:
	var coords := Vector3i(_coords.x, _coords.y, _coords.z)
	if coords_to_tile.has(coords):
		return coords_to_tile[coords]
	return null
	
func onAddToCoordsToTile(Tile: TileGD) -> void:
	coords_to_tile[Tile.getCoordsHeightless()] = Tile
	
func onResetCoordsToTile() -> void:
	coords_to_tile = {}
#endregion

#region Cube Directions
func getCubeDirectionRegular(index: int) -> Vector3i:
	return cube_directions[index]

func getCubeDirectionExtra(index: int) -> Vector4i:
	var d: Vector3i = getCubeDirectionRegular(index)
	return Vector4i(d.x, d.y, d.z, 0)
	
func getCubeDirectionsExtra() -> Array:
	return range(6).map(getCubeDirectionExtra)
#endregion
