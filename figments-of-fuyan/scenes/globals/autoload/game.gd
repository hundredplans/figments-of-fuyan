class_name Game extends Node

const SELECTED_MAP_NODE_TRAVEL_SPEED: float = 1
enum Rarities {SCRAP, NEUTRAL, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
enum ShopTypes {CARD, BOON, TOOL, DECK}
static func getRarityString(rarity: Rarities) -> String:
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

static func getShopType(shop_type: ShopTypes) -> String:
	match shop_type:
		ShopTypes.CARD: return "Card"
		ShopTypes.BOON: return "Boon"
		ShopTypes.TOOL: return "Tool"
		ShopTypes.DECK: return "Deck alteration"
	return "NULL"

static func isBasicRarity(rarity: int) -> bool:
	return rarity > 2 and rarity < 6
	
static func isChampion(rarity: int) -> bool:
	return rarity == 8
#func onStartActions() -> void:
	#if active_action == null:
		#active_action = actions.pop_front()
		#get_tree().call_group()
		#active_action.onProcess()

static func getCoordsDistance(coords: Vector4i, _coords: Vector4i) -> int	:
	var pos := Vector3(coords.x - _coords.x, coords.y - _coords.y, coords.z - _coords.z)
	return (abs(pos.x) + abs(pos.y) + abs(pos.z)) / 2
	
static func onCoordsToPosition(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)
