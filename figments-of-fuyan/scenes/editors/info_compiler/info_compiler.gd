extends Node

var GDSCRIPT_TYPES: Array = [AreaInfo, LevelInfo, \
	CardInfo, ChampionCardInfo, BoonInfo, ToolInfo, MapNodeInfo, SaveFileInfo, EncounterInfo,\
	TileObjectInfo, TileInfo, ObjectInfo, GameObjectInfo, TraitInfo, StatusEffectInfo, FieldEffectInfo,\
	LoreBookInfo, ArchetypeInfo, ActionWrapperInfo, VFXInfo, EpicCardInfo]

const FOF_INFO_DATASTORE_PATH: String = "res://resources/datastore/fof_info_datastore/fof_info_datastore.tres"
var dict: Dictionary = {}
func _ready() -> void:
	for type: GDScript in GDSCRIPT_TYPES:
		onRefreshFofInfoArray(type)
	
	var info: FofInfoDatastore = load(FOF_INFO_DATASTORE_PATH)
	info.setDict(dict)
	ResourceSaver.save(info)

func onRefreshFofInfoArray(type: GDScript) -> void: # DEV
	dict[type] = {}

	var DIR_PATH: String = type.getInfoPath()
	var fof_info_array: Array = Helper.getFilesRecursive(DIR_PATH)\
		.map(func(x: String): return load(x)).filter(func(x: FofInfo): return is_instance_of(x, type))
	
	if type == CardInfo:
		var ALT_DIR_PATH: String = "res://test/test_cards/"
		fof_info_array += Helper.getFilesRecursive(ALT_DIR_PATH).map(func(x: String): return load(x))
			
	for fof_info in fof_info_array:
		dict[type][fof_info.id] = fof_info
	
