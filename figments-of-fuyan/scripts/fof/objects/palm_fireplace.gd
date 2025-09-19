extends IObjectGD

# Make recharge at the end

const ABILITY_DELAY: float = 3.0
var was_extinguished: bool
var was_fuel_added: bool

const ATTACK_TURNS: int = 3

func onProcessAction(action: Action) -> void:
	super(action)

func onLoadDataLevel() -> void:
	super()

func isValidActiveEffect(Card: CardGD) -> bool:
	return super(Card) and Card.getTile() != null and isAdjacent(Card.getCoords()) and Card.getTile().getHeight() == getTile().getHeight()

func getActiveEffectTiles(_Card: CardGD) -> ActiveEffectTiles:
	return ActiveEffectTiles.new([getTile()], [getTile()])

func onActiveEffect(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	var Tile: TileGD = getTile()
	var change_tr_action := ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.getTile(), getTile()))
	change_tr_action.setActionDelay(ABILITY_DELAY)
	var actions: Array = [change_tr_action]
	var tiles: Array = Game.getAdjacentOrCloserTiles(Tile, 3)
	var units: Array = Game.get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return x.Tile in tiles)
	actions.append(StatAction.new(units.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1, ATTACK_TURNS))))
	was_extinguished = true
	actions.append(CameraChangeAction.new(Card))
	onPushAction(actions)
		
func onActiveEffectPre(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles, Card: CardGD) -> void:
	onExtinguishVFX()
	onForceAction(CameraChangeAction.new(self))
	
func onSave() -> SavedDataIObject:
	ability_save['was_extinguished'] = was_extinguished
	return super()

var SmokeParticle: GPUParticles3D
func onHiddenVFX() -> void:
	if !was_extinguished and SmokeParticle != null:
		SmokeParticle.queue_free()

func onVisibleDefaultVFX() -> void:
	if SmokeParticle == null:
		SmokeParticle = load(info.SMOKE_PARTICLE_SCENE_PATH).instantiate()
		SmokeParticle.position.y += 0.3
		add_child(SmokeParticle)
		if was_fuel_added: onAddFuelVFX()
	
func onUpdateLevelVisible() -> void:
	super()
	
	if isLevelVisible(): onVisibleDefaultVFX()
	else: onHiddenVFX()
	
func onAddFuelVFX() -> void:
	if SmokeParticle != null:
		SmokeParticle.amount_ratio = 1
	
func onExtinguishVFX() -> void:
	if SmokeParticle != null:
		SmokeParticle.emitting = false
		await SmokeParticle.finished
		SmokeParticle.queue_free()
		
# If used nothing, otherwise 50% chance to have +0.5 on adjacent tiles
const CHANCE_TO_APPLY_TRANSFORMS: float = 0.5
const POSITIVE_TRANSFORM_TO_ADJACENT_TILES: float = 0.5
func onIObjectSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	if was_extinguished or was_fuel_added: return
	if !DFL.Card.isInCombat(): return
	if !Random.rollFloat(CHANCE_TO_APPLY_TRANSFORMS): return
	
	var triple_adjacent_tiles: Array = Game.getAdjacentOrCloserTiles(getTile(), 3)
	for Tile: TileGD in tiles_to_value:
		if Tile in triple_adjacent_tiles:
			tiles_to_value[Tile] += POSITIVE_TRANSFORM_TO_ADJACENT_TILES
	
const AI_ALLIES_IN_VISION: int = 1
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return active_effect_tiles.pickable_tiles[0]
		
