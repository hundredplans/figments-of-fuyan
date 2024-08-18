extends Node

@export_group("Main Menu")
@export var main_menu_ui: PackedScene
@export var main_menu_world: PackedScene

#region Base Functions
func _ready():
	onLoadScreenWorld(main_menu_ui, main_menu_world)
#endregion

#region Load Screen + World
var ActiveScreen: Control
var ActiveWorld: Node3D

func onLoadScreenWorld(packed_ui: PackedScene, packed_world: PackedScene) -> void:
	onLoadScreen(packed_ui)
	onLoadWorld(packed_world)
	
	ActiveScreen.World = ActiveWorld
	ActiveWorld.UI = ActiveScreen
	
	add_child(ActiveScreen)
	add_child(ActiveWorld)

func onLoadScreen(packed_scene: PackedScene) -> void:
	if ActiveScreen != null: ActiveScreen.queue_free()
	ActiveScreen = packed_scene.instantiate()
	
func onLoadWorld(packed_scene: PackedScene) -> void:
	if ActiveWorld != null: ActiveWorld.queue_free()
	ActiveWorld = packed_scene.instantiate()
#endregion
