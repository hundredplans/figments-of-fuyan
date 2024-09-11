extends Node

@export_group("Main Menu")
@export var main_menu_ui: PackedScene
@export var main_menu_world: PackedScene

@export var map_ui: PackedScene
@export var map_world: PackedScene

@export var SHILLING_START_COUNT: int = 10

#region Base Functions
func _ready():
	if !Helper.getAdmin(): onLoadScreenWorld(main_menu_ui, main_menu_world)
	else:
		onLoadScreenWorld(map_ui, map_world)
		var node := Node3D.new()
		add_child(node)
		onStartGame(SavedData.onLoadModel(SavedDataCard.new(2), node))
#endregion

#region Load Screen + World
var ActiveScreen: Control
var ActiveWorld: Node3D

func onLoadScreenWorld(packed_ui: PackedScene, packed_world: PackedScene) -> Dictionary:
	onLoadScreen(packed_ui)
	onLoadWorld(packed_world)
	
	ActiveScreen.World = ActiveWorld
	ActiveWorld.UI = ActiveScreen
	
	add_child(ActiveScreen)
	add_child(ActiveWorld)
	return {"ui": ActiveScreen, "world": ActiveWorld}

func onLoadScreen(packed_scene: PackedScene) -> void:
	if ActiveScreen != null: ActiveScreen.queue_free()
	ActiveScreen = packed_scene.instantiate()
	
func onLoadWorld(packed_scene: PackedScene) -> void:
	if ActiveWorld != null: ActiveWorld.queue_free()
	ActiveWorld = packed_scene.instantiate()
	
	match packed_scene:
		main_menu_world: ActiveWorld.start.connect(onStartGame)
	
func onStartGame(_Card: CardGD) -> void:
	var scenes: Dictionary = onLoadScreenWorld(map_ui, map_world)
	var area_id: int = 1
		
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	var area: AreaGD = SavedData.onLoadModel(SavedDataArea.new(area_id, area_info.overworld_info.id, MapLocation.new(-1, 0, area_id)), scenes.world)
	
	var save_file_data := SavedDataSaveFile.new(getFirstEmptySaveSlotID(), randi(), area.onSave(), SHILLING_START_COUNT)
	
	var save_file: SaveFileGD = SavedData.onLoadModel(save_file_data, scenes.world)
	save_file.area = area
	
	var Card: CardGD = SavedData.onLoadModel(SavedDataCard.new(_Card.info.id), scenes.world)
	Card.onAddToDeck()
	
	scenes.ui.onLoad(save_file)
	scenes.world.onLoad(save_file, Card)
	
	area.onCreateMapNodes(Card)
	
func getFirstEmptySaveSlotID() -> int:
	return min(DirAccess.get_files_at(SaveFileInfo.SAVE_DIRECTORY).size() + 1, 5)
#endregion
