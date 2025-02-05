extends IObjectGD

const COCONUT_ID: int = 13
const COCONUT_DROP_ODDS: float = 0.25
const ACTION_DELAY: float = 1
const RECHARGE_MIN_TURN: int = 4
const RECHAGRE_MAX_TURN: int = 8
var recharge: int
var coconut_tiles: Array

func isAttackable(_Card: CardGD) -> bool:
	return true

func getAttackableTile() -> TileGD:
	return occupied_tiles[0]

func onWasDamaged(action: DamageAction) -> void:
	if recharge == 0:
		var iobject_damaged_action := IObjectDamagedAction.new(self, action)
		iobject_damaged_action.setActionDelay(ACTION_DELAY)
		onPushAction(iobject_damaged_action)
	
func onIObjectDamagedPre(_action: DamageAction) -> void:
	coconut_tiles = []
	var tiles: Array = Game.getAdjacentTiles(getAttackableTile())
	for Tile in tiles.filter(func(x: TileGD): return !x.occupied_objects.any(func(y: ObjectGD): return y.info.id == COCONUT_ID)):
		if !Random.rollFloat(COCONUT_DROP_ODDS): continue
		coconut_tiles.append(Tile)
	
func onAdvanceTurn(team: int) -> void:
	super(team)
	if team == 0:
		recharge = max(recharge - 1, 0)

func onIObjectDamaged(_action: DamageAction) -> void:
	var actions: Array = []
	var damage_actions: Array = []
	for Tile in coconut_tiles:
		var Card: CardGD = Game.getFieldCard(Tile)
		if Card == null:
			actions.append(CreateObjectAction.new(COCONUT_ID, Tile))
		else: damage_actions.append(DamageAction.new(self, Card, 1))
		
	actions += damage_actions
	recharge = range(RECHARGE_MIN_TURN, RECHAGRE_MAX_TURN + 1).pick_random()
	onPushAction(actions)

func onSave() -> SavedDataIObject:
	ability_save['recharge'] = recharge
	return super()

const NEGATIVE_TRANSFORM: float = -10
const POSITIVE_TRANSFORM: float = 0.5
# If recharging, the unit is one health or if the unit is not in combat give a -10, otherwise +0.5
func onIObjectSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	if !tiles_to_value.has(getAttackableTile()): return
	tiles_to_value[getAttackableTile()] += NEGATIVE_TRANSFORM if (recharge > 0 or DFL.Card.health == 1 or !DFL.Card.isInCombat()) else POSITIVE_TRANSFORM
	
