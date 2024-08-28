extends Node

@export_group("Main Menu")
@export var main_menu_ui: PackedScene
@export var main_menu_world: PackedScene

@export var map_ui: PackedScene
@export var map_world: PackedScene

#region Base Functions
func _ready():
	onLoadScreenWorld(main_menu_ui, main_menu_world)
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
	
func onStartGame(Unit: UnitGD) -> void:
	var save_file := SaveFile.new()
	var scenes: Dictionary = onLoadScreenWorld(map_ui, map_world)
	scenes.ui.onLoad(save_file)
	scenes.world.onLoad(save_file, Unit)
#endregion
