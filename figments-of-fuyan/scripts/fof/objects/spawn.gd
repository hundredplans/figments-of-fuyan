class_name SpawnGD
extends ObjectGD
var spawn_id: int
var groups: Array

var GroupLabel: Label3D # Set by level editor

func onLoadData(data: SavedData) -> void:
	groups = data.groups
	super(data)
	spawn_id = data.spawn_id
	add_to_group("SpawnsGD")
	match variation:
		0: add_to_group("AllySpawnsGD")
		1: add_to_group("EnemySpawnsGD")
		2: add_to_group("NeutralSpawnsGD")

func onLoadModel() -> void:
	super()
	GroupLabel = load(info.SPAWN_GROUP_LABEL_SCENE_PATH).instantiate()
	Model.add_child(GroupLabel)
	GroupLabel.setInfo(groups)

func onLoadDataLevelFofInit() -> void:
	super()
	if is_in_group("AllySpawnsGD"):
		var revealed_datastore := Game.onCreateRevealedDatastore(self, 0)
		onPushAction(RevealAction.new(self, revealed_datastore))
		
	if spawn_id == 0: return
	
	get_tree().get_nodes_in_group("AreasGD")[0].basic_card_ids.pick_random()
	var Tile: TileGD = getTile()
	var Card: CardGD = Game.getNewFieldCard(spawn_id, Tile, variation, tile_rotation, false)
	
	onPushAction(AwakenAction.new(Card, Tile))

func onToolPickedUp(action: OccupyAction) -> void:
	onClear()
	var Tool: ToolGD = SavedData.onLoadModel(Helper.getFofInfoID(ToolInfo, spawn_id).saved_data.new(spawn_id, true), action.Card)
	onPushAction(AddToolAction.new(action.Card, Tool))

func onSave() -> SavedDataSpawn:
	return SavedDataSpawn.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, variation, map_rotation, map_position, height,\
	occupied_tiles.map(func(x: TileGD): return x.getCoords()), spawn_id, groups)

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
	if SpawnParticle == null: return
	SpawnParticle.onOccupy(state)

func onChangeSpawnGroup(char: String) -> void:
	if !groups.has(char): groups.append(char)
	else: groups.erase(char)
	
	GroupLabel.setGroups(groups)
	
