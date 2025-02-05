class_name DefaultFightLogic extends Behaviour

const FALL_DAMAGE_DEATH_DECENTIVIZATION: float = -10.0

var Card: CardGD
var tiles: Array
var enemies: Array
var allies: Array
var pacifist: bool

var is_kill_guaranteed: bool
var temp_att: int
var path: Array
var is_card_attack: bool # Non lethal attack on a Card

func _init(_Card: CardGD, _tiles: Array = [], _enemies: Array = [], _allies: Array = [], _pacifist: bool = false) -> void:
	Card = _Card
	tiles = _tiles
	enemies = _enemies
	allies = _allies
	pacifist = _pacifist

func getTilesDFL() -> DFLData:
	var KillTile: TileGD = getKillTile()
	if KillTile != null:
		return DFLData.new({}, KillTile)
		
	var tiles_to_value: Dictionary = {}
	
	for Tile in tiles:
		tiles_to_value[Tile] = getFallDamageTileValue(Card, Tile) # 1 by default
	
	for IObject in Card.getVisibleGameObjects().filter(func(x: GameObjectGD): return x is IObjectGD):
		IObject.onIObjectSpecificTransforms(tiles_to_value, self)
	
	Card.onUnitSpecificTransforms(tiles_to_value, self)
	return DFLData.new(tiles_to_value, null)
	
func getFallDamageTileValue(FallCard: CardGD, Tile: TileGD) -> float:
	var total_damage: int = 0
	for MovementPathTile in Tile.getMovementPathTiles():
		var fall_damage: int = Tile.getFallDamage(MovementPathTile)
		total_damage += fall_damage
	
	if !FallCard.isCardSurviveFallDamage(total_damage):
		return FALL_DAMAGE_DEATH_DECENTIVIZATION
	elif total_damage > 0:
		return 0.5
	return 1.0
	
#region Temp Stats
func onAddTempAtt(delta: int) -> void:
	temp_att += delta
#endregion

#region Getters
func getEnemies() -> Array:
	return enemies
	
func getAllies() -> Array:
	return allies
	
func getTiles() -> Array:
	return tiles
	
func getPath() -> Array:
	return path

func getIsCardAttack() -> bool:
	return is_card_attack
	
func getIsKillGuaranteed() -> bool:
	return is_kill_guaranteed
#endregion

#region Setters
func setPath(_path: Array) -> void:
	path = _path
	is_card_attack = !path.is_empty() and path[path.size() - 1] in Game.getEnemyUnits(Card.team).map(func(x: CardGD): return x.getTile())
#endregion

#region Combat
# If there's a killable unit get the best one
func getKillTile() -> TileGD:
	if pacifist: return null
	var local_enemies: Array = enemies.duplicate()
	local_enemies = local_enemies.filter(func(x: CardGD): return Card.isGameObjectAttackable(x, x.Tile))
	local_enemies = local_enemies.filter(func(x: CardGD): return x.getTile() in tiles)
	local_enemies = local_enemies.filter(isAttackableKillable.bind(Card))
	local_enemies.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
	local_enemies.shuffle()
	is_kill_guaranteed = !local_enemies.is_empty()
	return local_enemies[0].Tile if is_kill_guaranteed else null
	
func isAttackableKillable(Defender: CardGD, Damager: CardGD) -> bool:
	var damage_action := GetDamageAction.new(Damager, Defender, Damager.getAttackDamage() + temp_att)
	Damager.onForceAction(damage_action)
	return damage_action.damage >= Defender.health
	
# Returns an updated path if in the chosen Tile's path there's an attackable in range
func onTileChosenGetUpdatedAttackablePath(updated_path: Array) -> Array:
	if updated_path.is_empty(): return []
	if pacifist: return  updated_path
	if is_kill_guaranteed: return updated_path
	
	var LastTile: TileGD = updated_path[updated_path.size() - 1]
	if enemies.any(func(x: CardGD): return x.getTile() == LastTile): return updated_path
	
	var attackables: Array = Card.getAttackablesInRange(LastTile).keys()
	
	# If their Tile is inside unit's movement range
	attackables = attackables.filter(func(x: GameObjectGD): return !x.getTile().getMovementPathTilesSafe().is_empty())
	attackables = attackables.filter(func(x: GameObjectGD): return x is CardGD)
	if attackables.is_empty(): return updated_path
	
	attackables.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
	return attackables[0].getTile().getMovementPathTiles()
#endregion
