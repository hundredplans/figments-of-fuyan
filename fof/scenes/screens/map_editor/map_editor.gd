extends Control

const TID: int = 7
const FILE_LOADER_NAME: String = "Map"

@onready var NodeArrows: Node2D = $MapMenu/NodeArrows
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
	on_create_default_map()
	on_select_node_type(0)
	for button in NodeButtons.get_children():
		button.pressed.connect(on_select_node_type.bind(int(str(button.name))))

func on_autofill_nodes() -> void:
	for node_container in Nodes.get_children():
		on_node_texture_pressed(node_container.get_child(map_size - 1), 1)

	on_node_texture_pressed(get_node("MapMenu/Nodes/1").get_child(5), 3)
	on_node_texture_pressed(get_node("MapMenu/Nodes/1").get_child(0), 4)
	
func on_change_map_size(i: int, alter: bool = true):
	var omapsize: int = map_size
	map_size = clamp(map_size + i, 5, 15)
	NodeAmount.text = str(map_size)
	
	if alter:
		if map_size > omapsize:
			on_load_empty_node_row()
			on_add_arrows_to_row(1)
			call_deferred("on_recreate_arrows")
			
		elif map_size < omapsize:
			for node_container in Nodes.get_children():
				node_container.get_child(0).free()
				for child in node_container.get_child(0).get_node("NodeArrows").get_children(): child.queue_free()
			call_deferred("on_remove_dead_arrows")

func on_recreate_arrows() -> void:
	for arrow in NodeArrows.get_children():
		arrow.from.y += 1
		arrow.to.y += 1
		arrow.on_create_arrow(arrow.from, arrow.to, Nodes)
			
func on_remove_dead_arrows() -> void:
	for arrow in NodeArrows.get_children():
		if arrow.to.y == 0:
			arrow.from.y = 0
			on_destroy_arrow(arrow)
		else:
			arrow.from.y -= 1
			arrow.to.y -= 1
			arrow.on_create_arrow(arrow.from, arrow.to, Nodes)
func on_destroy_arrow(arrow: Line2D) -> void:
	if arrow.from.y != 0:
		var arrow_type: int = 1
		if arrow.from.x > arrow.to.x: arrow_type = 2
		elif arrow.from.x < arrow.to.x: arrow_type = 0
		add_selectable_arrow(Nodes.get_child(arrow.from.x).get_child(arrow.from.y), arrow_type)
		
	for i in range(disabled_arrow_selectors_arrows.size()):
		if disabled_arrow_selectors_arrows[i] == arrow:
			disabled_arrow_selectors[i].modulate = Color(1,1,1,1)
			disabled_arrow_selectors[i].disabled = false
			break
	arrow.queue_free()
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
		NodeButton.is_inside.connect(on_node_button_is_inside)
		
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
	TxBtn.pressed.connect(on_arrow_node_pressed.bind(NodeButton, TxBtn, arrow_type))
	TxBtn.name = str(arrow_type)
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
	
const NODE_OFFSET := Vector2(25, 35)
const ARROW_CONVERSION: Dictionary = {
	"0": 1,
	"1": 0,
	"2": -1,
}

var disabled_arrow_selectors: Array = []
var disabled_arrow_selectors_arrows: Array = []
var _NodeArrow: PackedScene = preload("res://scenes/screens/map_editor/node_arrow.tscn")
func on_arrow_node_pressed(NodeButton: Control, Arrow: TextureButton, arrow_type: int) -> void:
	Arrow.queue_free()
	var NodeArrow: Line2D = _NodeArrow.instantiate()
	NodeArrows.add_child(NodeArrow)
	
	var TargetButton: Control = Nodes.get_node(str(int(str(NodeButton.get_parent().name)) + ARROW_CONVERSION[str(arrow_type)])).get_child(NodeButton.get_index() - 1)
	NodeArrow.on_create_arrow(Vector2i(int(str(NodeButton.get_parent().name)), NodeButton.get_index()), Vector2i(int(str(TargetButton.get_parent().name)), TargetButton.get_index()), Nodes)
	NodeArrow.destroy_arrow.connect(on_destroy_arrow)
	
	if arrow_type != 1:
		var TargetArrow: Control = Nodes.get_child(NodeArrow.to.x).get_child(NodeArrow.to.y + 1).get_node("NodeArrows/" + str(abs(arrow_type - 2)))
		TargetArrow.disabled = true
		TargetArrow.modulate = Color(0.5, 0.5, 0.5, 1)
		
		disabled_arrow_selectors.append(TargetArrow)
		disabled_arrow_selectors_arrows.append(NodeArrow)

func on_create_default_map() -> void:
	map_size = 10
	for node_container in Nodes.get_children():
		for child in node_container.get_children(): child.queue_free()
	for arrow in NodeArrows.get_children(): arrow.queue_free()
	on_create_default_map_deferred.call_deferred()
	
	world_selected = 1
	$SaveMenu/WorldSelector.default = 1
	$SaveMenu/WorldSelector.set_grabber_position()
	$SaveMenu/EditFileName.set_text("", "")
	on_select_node_type(0)

func on_create_default_map_deferred():
	on_change_map_size(0, false)
	for n in range(map_size): on_load_empty_node_row()
	for n in range(1, map_size): on_add_arrows_to_row(n)
	on_autofill_nodes()

func on_node_button_is_inside() -> void:
	for arrow in NodeArrows.get_children(): arrow.can_press = false
func _on_world_selector_item_selected(i: int):
	world_selected = i

func _on_save_map_pressed():
	pass # Replace with function body.
