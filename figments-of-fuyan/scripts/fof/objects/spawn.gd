class_name SpawnGD
extends ObjectGD
var spawn_id: int
var GroupLabel: Label3D # Set by level editor

func onLoadData(data: SavedData) -> void:
	super(data)
	spawn_id = data.spawn_id
	add_to_group("SpawnsGD")
	match variation:
		0: add_to_group("AllySpawnsGD")
		1: add_to_group("EnemySpawnsGD")
		2: add_to_group("NeutralSpawnsGD")
		3: add_to_group("EnemySpawnsGD"); add_to_group("BossSpawnsGD")

func onLoadModel() -> void:
	super()
	GroupLabel = load(info.SPAWN_GROUP_LABEL_SCENE_PATH).instantiate()
	Model.add_child(GroupLabel)
	GroupLabel.setInfo(groups)

func onLoadDataLevelFofInit() -> void:
	super()
		
	if spawn_id == 0: return
	
	get_tree().get_nodes_in_group("AreasGD")[0].basic_card_ids.pick_random()
	var Tile: TileGD = getTile()
	
	if variation != 3: # Not Boss
		var Card: CardGD = Game.getNewFieldCard(spawn_id, Tile, variation, tile_rotation, false)
		onPushAction(AwakenAction.new(Card, Tile))
	else: onAwakenBoss(Tile)

func onAwakenBoss(Tile: TileGD) -> void:
	var boss_info: EpicCardInfo = Helper.getFofInfoID(EpicCardInfo, spawn_id)
	var boss_datastore := BossDatastore.new(1, boss_info.getAwakenBossIntentName())
	onPushAction(AwakenBossAction.new(spawn_id, Tile, boss_datastore))

func onToolPickedUp(action: OccupyAction) -> void:
	onClear()
	var Tool: ToolGD = SavedData.onLoadModel(Helper.getFofInfoID(ToolInfo, spawn_id).saved_data.new(spawn_id, true), action.Card)
	onPushAction(AddToolAction.new(action.Card, Tool))

func onSave() -> SavedDataSpawn:
	return SavedDataSpawn.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, variation, map_rotation, map_position, height,\
	occupied_tiles.map(func(x: TileGD): return x.getCoords()), spawn_id)

var SpawnParticle: GPUParticles3D
func onLoadDataLevel() -> void:
	super()
	Model.visible = false
	setCollisionLayers(0)
	
	if variation == 0:
		SpawnParticle = load(info.SPAWN_PARTICLE_SCENE_PATH).instantiate()
		add_child(SpawnParticle)

func isSpawnOccupied() -> bool:
	return occupied_tiles.any(func(x: TileGD): return x.isOccupied())
	
func getTile() -> TileGD:
	return occupied_tiles[0]
	
func onOccupy(state: bool) -> void:
	super(state)
	if SpawnParticle == null: return
	SpawnParticle.onOccupy(state)

func onChangeSpawnGroup(group_name: String) -> void:
	if !groups.has(group_name): groups.append(group_name)
	else: groups.erase(group_name)
	
	GroupLabel.setGroups(groups)
	
func isInLevelGroup() -> String:
	return Game.getLevel().getSpawnGroup() in groups
	
