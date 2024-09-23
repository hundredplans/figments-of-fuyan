extends Node

var ActionManagerReference: ActionManagerGD
const SELECTED_MAP_NODE_TRAVEL_SPEED: float = 1
enum Rarities {SCRAP, NEUTRAL, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
enum ShopTypes {CARD, BOON, TOOL, DECK}
enum Phases {NULL, START, HAND, PLAYER, AI, NEUTRAL}
enum SpectateTypes {ALLY, ENEMY, SPAWN}

var CARD_PLACES_TO_GROUP: Dictionary = {
	CardGD.CARD_PLACES.NULL: "",
	CardGD.CARD_PLACES.HAND: "HandCardsGD",
	CardGD.CARD_PLACES.DECK: "DeckCardsGD",
	CardGD.CARD_PLACES.FIELD: "FieldCardsGD"
}

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
func getCoordsDistance(coords: Vector4i, _coords: Vector4i) -> int	:
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
#endregion

#region Units
func getAllyUnits(team: int = 0) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.team == team)
	
func getEnemyUnits(team: int = 0) -> Array:
	return get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.team != team)
#endregion
	
