class_name DefaultFightLogic extends Behaviour

const FALL_DAMAGE_DEATH_DECENTIVIZATION: float = -10.0

var Card: CardGD
var tiles: Array
var enemies: Array
var allies: Array
var pacifist: bool

var kill_rolled: bool

var temp_att: int
var path: Array
var is_card_attack: bool # Non lethal attack on a Card

var kill_path: Array

func _init(_Card: CardGD, _tiles: Array = [], _enemies: Array = [], _allies: Array = [], _pacifist: bool = false, _kill_rolled: bool = false) -> void:
	Card = _Card
	tiles = _tiles
	enemies = _enemies
	allies = _allies
	pacifist = _pacifist
	kill_rolled = _kill_rolled

func getTilesDFL() -> DFLData:
	if !kill_rolled:
		kill_path = getKillPath()
		if !kill_path.is_empty():
			return DFLData.new({}, kill_path)
		
	var tiles_to_value: Dictionary = {}
	for Tile: TileGD in tiles:
		tiles_to_value[Tile] = getFallDamageTileValue(Card, Tile) # 1 by default
	
	for IObject in Card.getVisibleGameObjects().filter(func(x: GameObjectGD): return x is IObjectGD):
		IObject.onIObjectSpecificTransforms(tiles_to_value, self)
	
	Card.onUnitSpecificTransforms(tiles_to_value, self)
	return DFLData.new(tiles_to_value)
	
func getFallDamageTileValue(FallCard: CardGD, Tile: TileGD) -> float:
	var total_damage: int = 0
	var movement_path: Array = Tile.getMovementPathTiles()
	
	for i in range(1, movement_path.size()):
		var fall_damage: int = movement_path[i].getFallDamage(movement_path[i - 1])
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
#endregion

#region Setters
func setPath(_path: Array) -> void:
	path = _path
	is_card_attack = !path.is_empty() and path[path.size() - 1] in Game.getEnemyUnits(Card.team).map(func(x: CardGD): return x.getTile())
#endregion

#region Combat
# If there's a killable unit get the best one
func getKillPath() -> Array:
	if pacifist: return []
	
	var local_enemies: Array = enemies.duplicate()
	local_enemies = local_enemies.filter(func(x: CardGD): return Card.isValidAttackableInRangeSpeed(x, Card.getTile()))
	local_enemies = local_enemies.filter(func(x: CardGD): return x.getTile() in tiles)
	local_enemies = local_enemies.filter(isAttackableKillable.bind(Card))
	
	local_enemies.shuffle()
	local_enemies.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
	if !local_enemies.is_empty():
		var KillCard: CardGD = local_enemies[0]
		if isKillOdds(KillCard):
			kill_rolled = true
			var EnemyTile: TileGD = KillCard.getTile()
			var tiles_in_attack_range: Array = tiles\
				.filter(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), EnemyTile.getCoords()) <= Card.getAttackRange())\
				.filter(Card.isValidAttackTile.bind(KillCard))
			
			var attack_path: Array = tiles_in_attack_range.pick_random().getMovementPathTiles()
			if attack_path[attack_path.size() - 1] != EnemyTile:
				attack_path.append(EnemyTile)
			return attack_path
	return []
	
var BASE_KILL_ODDS: float = 1.0 # 100%
func isKillOdds(KillCard: CardGD) -> bool:
	var path_tiles: Array = KillCard.getTile().getMovementPathTiles()
	var AttackTile: TileGD = path_tiles[path_tiles.size() - 2]
	var attack_coords: Vector4i = AttackTile.getCoords()
	
	var enemies: Array = Game.getEnemyUnits(Card.team)\
		.filter(func(x: CardGD): return x not in [KillCard, Card] and Game.getCoordsDistance(x.getCoords(), attack_coords) <= x.getAttackRange() + x.max_speed)
	var allies: Array = Game.getAllyUnits(Card.team)\
		.filter(func(x: CardGD): return x not in [KillCard, Card] and Game.getCoordsDistance(x.getCoords(), attack_coords) <= x.getAttackRange() + x.max_speed)
		
	allies = allies.map(func(x: CardGD): return x.attack)
	enemies = enemies.map(func(x: CardGD): return x.attack)
		
	var potential_enemy_attack: int = enemies.reduce(func(x: int, y: int): return x + y, 0)
	var potential_ally_attack: int = allies.reduce(func(x: int, y: int): return x + y, 0)
	var potential_tile_attack: int = max(potential_enemy_attack - potential_ally_attack, 0) # Ally here is an enemy unit
	
	var as_health_total: float = (float(potential_tile_attack) / float(Card.health)) if Card.health > 0 else 0
	as_health_total += 1
	
	if potential_enemy_attack >= Card.health:
		var energy_diff: float = (max(float(Card.energy), 1.0) / max(float(KillCard.energy), 1.0))
		as_health_total *= energy_diff # Lower = better
			
	var odds: float = BASE_KILL_ODDS / as_health_total
	return Random.rollFloat(odds)
	
func onSortKillValue(x: CardGD, y: CardGD) -> bool:
	if x.energy != y.energy: return x.energy > y.energy
	return x.health > y.health
	
func isAttackableKillable(Defender: CardGD, Damager: CardGD) -> bool:
	var damage_action := GetDamageAction.new(Damager, Defender, Damager.getAttackDamage() + temp_att)
	Damager.onForceAction(damage_action)
	return damage_action.damage >= Defender.health
	
# Returns an updated path if in the chosen Tile's path there's an attackable in range
func onTileChosenGetUpdatedAttackablePath(updated_path: Array) -> Array:
	if updated_path.is_empty(): return []
	if pacifist: return updated_path
	if !kill_path.is_empty(): return updated_path
	
	var attackables_dict: Dictionary = {}
	for PathTile: TileGD in updated_path:
		var path_tile_attackables: Array = Card.getAttackablesInAttackRange(PathTile).keys()
		for GameObject: GameObjectGD in path_tile_attackables:
			attackables_dict[GameObject] = null
			
	var attackables: Array = attackables_dict.keys()
	attackables = attackables.filter(func(x: GameObjectGD): return x is CardGD)
	if attackables.is_empty(): return updated_path
	
	attackables.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
	return attackables[0].getTile().getMovementPathTiles()
#endregion
