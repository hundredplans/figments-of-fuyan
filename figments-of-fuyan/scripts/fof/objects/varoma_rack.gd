extends IObjectGD
const ARMOR_TRAIT_ID: int = 1
const ARMOR_AMOUNT: int = 1

const RANGED_TRAIT_ID: int = 2
const RANGED_AMOUNT: int = 2

var used_rack_cards: Array = []
var used_rack_cards_public_ids: Array = []

var last_seen_invisible_model_count: int
var invisible_model_count: int
var variation_to_model_name: Dictionary = {
	0: "Shield",
	1: "Helmet",
	2: "Sword",
	3: "Spear"
}

func onProcessAction(action: Action) -> void:
	super(action)
	
func getValidActiveEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	return [getVariationActiveEffect()] if isAdjacent(Card.getCoords()) else []
	
func isActiveEffectDisabled(Card: CardGD) -> bool:
	return super(Card) or Card in used_rack_cards
	
func getVariationActiveEffect() -> bool: # Remove this later
	return false
	
func onActiveEffect(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	var actions: Array = []
	match variation:
		0: # Shield
			actions.append(Card.onGainShieldAction())
		1: # Armor
			var armor_trait_data := SavedDataTrait.new(ARMOR_TRAIT_ID, true, 0, ARMOR_AMOUNT)
			var armor_overworld := OverworldTrait.new(armor_trait_data, OverworldTrait.AddedBy.VAROMA_RACK, true)
			actions.append(AddOverworldTraitAction.new(Card, armor_overworld, true))
		2: # Sword
			actions.append(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, 1)))
		3: # Spear
			var ranged_trait_data := SavedDataTrait.new(RANGED_TRAIT_ID, true, 0, RANGED_AMOUNT)
			var ranged_overworld := OverworldTrait.new(ranged_trait_data, OverworldTrait.AddedBy.VAROMA_RACK, true)
			actions.append(AddOverworldTraitAction.new(Card, ranged_overworld, true))
	
	invisible_model_count += 1
	if isLevelVisible(): last_seen_invisible_model_count = invisible_model_count
	onUpdateVisibleModels()
	
	used_rack_cards.append(Card)
	actions.append(CameraChangeAction.new(Card))
	onPushAction(actions)
	
func onUpdateVisibleModels() -> void:
	var model_one: MeshInstance3D = Model.get_node(variation_to_model_name[variation] + "1")
	var model_two: MeshInstance3D = Model.get_node(variation_to_model_name[variation] + "2")
	model_one.visible = last_seen_invisible_model_count == 0
	model_two.visible = last_seen_invisible_model_count != 2
	
func onActiveEffectPre(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	onForceAction(CameraChangeAction.new(self))
	onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.getTile(), getTile())))

func onSave() -> SavedDataIObject:
	ability_save['used_rack_cards_public_ids'] = used_rack_cards.map(func(x: CardGD): return x.public_id)
	ability_save['last_seen_invisible_model_count'] = last_seen_invisible_model_count
	ability_save['invisible_model_count'] = invisible_model_count
	return super()

func onLoadData(data: SavedData) -> void:
	super(data)
	used_rack_cards = used_rack_cards_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
	
func onUpdateLevelVisible() -> void:
	super()
	if isLevelVisible():
		last_seen_invisible_model_count = invisible_model_count
		onUpdateVisibleModels()
	
func onLoadDataLevel() -> void:
	super()
	onUpdateVisibleModels()

func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return active_effect_tiles.pickable_tiles[0]
