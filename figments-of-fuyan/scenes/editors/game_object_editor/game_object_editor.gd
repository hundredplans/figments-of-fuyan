extends Node

#region Exports
@export var SCROLL_DELAY: float = 0.2
@export var TILE_OBJECTS_PATH: String = "res://resources/game/tile_object/info/"
#endregion
#region Globals
var all_game_objects: Array = []
@onready var World: Node3D = $World
@onready var GameObjectsContainer: VBoxContainer = %GameObjectsContainer
#endregion
#region Base Functions
func _ready() -> void:
	var all_tile_objects: Array = Helper.getResourcesRecursive(TILE_OBJECTS_PATH, TileObjectInfoGD)
	all_tile_objects.sort_custom(func(x: TileObjectInfoGD, y: TileObjectInfoGD): return x.id < y.id)
	
	all_game_objects = all_tile_objects
	
	for info in all_game_objects:
		var button := Button.new()
		button.text = info.name
		button.pressed.connect(onGameObjectInfoSelected.bind(info))
		GameObjectsContainer.add_child(button)
	onGameObjectInfoSelected(all_game_objects[0])
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ChangeVariationDown"):
		onChangeVariation(-1)
	elif Input.is_action_just_pressed("ChangeVariationUp"):
		onChangeVariation(1)
#endregion
#region Selecting Info
var SelectedModel: GameObjectGD
func onGameObjectInfoSelected(info: GameObjectInfoGD, data: GameObjectDataGD = info.createData()) -> void:
	if SelectedModel != null: SelectedModel.queue_free()
	SelectedModel = data.onLoad(World, info)
	
#endregion
#region Variations
var is_scroll_disabled: bool = false
func onChangeVariation(direction: int) -> void:
	if !is_scroll_disabled:
		SelectedModel.clampVariation(direction)
		onGameObjectInfoSelected(SelectedModel.info, SelectedModel.data)
		onDisableScroll()
	
func onDisableScroll() -> void:
	is_scroll_disabled = true
	await get_tree().create_timer(SCROLL_DELAY).timeout
	is_scroll_disabled = false
#endregion
