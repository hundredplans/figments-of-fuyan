extends Control

const TID: int = 7
const FILE_LOADER_NAME: String = "Map"

@onready var NodeButtons: Control = $NodeMenu/NodeSelectType/NodeButtons
@onready var NodeAmount: Label = $NodeMenu/AmountMenu/NodeAmount
var selected_node_type: int = 0
var map_size: int = 10
var world_selected: int = 1

func _process(_delta: float) -> void:
	if WheelButton and Input.is_action_just_released("LeftClick"):
		if WheelNode.node_type > 0:
			on_node_texture_pressed(WheelButton, WheelNode.node_type)
		WheelNode.queue_free()
		WheelNode = null
		WheelButton = null

func _ready() -> void:
	for n in range(map_size): on_load_empty_node_row()
	for n in range(1, map_size): on_add_arrows_to_row(n)
	on_autofill_nodes()
	
	on_select_node_type(0)
	on_change_map_size(0)
	for button in NodeButtons.get_children():
		button.pressed.connect(on_select_node_type.bind(int(str(button.name))))

func on_autofill_nodes() -> void:
	for node_container in Nodes.get_children():
		on_node_texture_pressed(node_container.get_child(map_size - 1), 1)

	on_node_texture_pressed(get_node("MapMenu/Nodes/1").get_child(5), 3)
	on_node_texture_pressed(get_node("MapMenu/Nodes/1").get_child(0), 4)
	
func on_change_map_size(i: int):
	var omapsize: int = map_size
	map_size = clamp(map_size + i, 5, 15)
	NodeAmount.text = str(map_size)
	
	if map_size > omapsize:
		on_load_empty_node_row()
		on_add_arrows_to_row(1)
		
	elif map_size < omapsize:
		for node_container in Nodes.get_children():
			node_container.get_child(0).queue_free()
			for child in node_container.get_child(1).get_node("NodeArrows").get_children(): child.queue_free()

func on_select_node_type(i: int, change_selected: bool = true) -> void:
	if change_selected:
		$SelectedNodeType.texture = load("res://scenes/screens/map_editor/node_types/" + str(i) + ".png")
	selected_node_type = i

@onready var Nodes: Control = $MapMenu/Nodes
var _NodeButton: PackedScene = preload("res://scenes/screens/map_editor/node_button.tscn")
func on_load_empty_node_row() -> void:
	for node_container in Nodes.get_children():
		var NodeButton: Control = _NodeButton.instantiate()
		NodeButton.size_flags_vertical = SIZE_EXPAND_FILL
		NodeButton.size_flags_horizontal = SIZE_EXPAND_FILL
		
		NodeButton.held.connect(on_node_texture_held)
		NodeButton.pressed.connect(on_node_texture_pressed)
		NodeButton.remove_node_texture.connect(on_node_texture_pressed)
		
		node_container.add_child(NodeButton)
		node_container.move_child(NodeButton, 0)

func on_add_arrows_to_row(row: int) -> void:
	for node_container in Nodes.get_children():
		var parent_num: int = int(str(node_container.name))
		for i in (range(3) if parent_num == 1 else [parent_num, 1]):
			add_selectable_arrow(node_container.get_child(row), i)

const ARROW_OFFSET: Vector2 = Vector2(-25, -22)
func add_selectable_arrow(NodeButton: Control, arrow_type: int) -> void:
	var TxBtn := TextureButton.new()
	TxBtn.texture_normal = load("res://scenes/screens/map_editor/node_arrows/" + str(arrow_type) + ".png")
	TxBtn.position = ARROW_OFFSET
	Helper.create_button_clickmask(TxBtn)
	NodeButton.get_node("NodeArrows").add_child(TxBtn)
		
func on_node_texture_pressed(NodeButton: Control, node_type: int = selected_node_type) -> void:
	NodeButton.node_texture = node_type
	NodeButton.get_node("NodeTexture").texture_normal = load("res://scenes/screens/map_editor/node_types/"+str(node_type)+".png")

var WheelButton: Control
var WheelNode: Control
func on_node_texture_held(NodeButton: Control) -> void:
	WheelButton = NodeButton
	WheelNode = preload("res://scenes/screens/map_editor/wheel_node_select.tscn").instantiate()
	WheelNode.position = Vector2(WheelButton.global_position.x + 65, WheelButton.global_position.y + 28)
	add_child(WheelNode)
	
