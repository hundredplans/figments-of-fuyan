extends Control
signal fileloader_state
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

func _on_save_map_pressed(do_popup: bool = true):
	if !on_find_error("null-arrows", do_popup) and !on_find_error("empty-level", do_popup) and !on_find_error("completable", do_popup):
		var contents: String = "%s\n%s\n%s\n%s" % [str(world_selected), str(map_size),
		
		str(Helper.flatten(Nodes.get_children().map(func(c: Control): return c.get_children()), false)\
		.filter(func(x: Control): return x.node_texture > 0)\
		.map(func(y: Control): return [y.node_texture, int(str(y.get_parent().name)), y.get_index()])),
		
		str(NodeArrows.get_children().map(func(x: Line2D): return [[x.from.x, x.from.y], [x.to.x, x.to.y]]))]
		Helper.write_to_base_game_file(FILE_LOADER_NAME, $SaveMenu/EditFileName, contents, TID)

func on_find_error(error_name: String, do_popup: bool) -> bool:
	match error_name:
		"null-arrows":
			if Nodes.get_children().map(func(x: Control): return x.get_child(map_size - 1)).all(func(y: Control): return y.node_texture != 0):
				for arrow in NodeArrows.get_children():
					for type in ["to", "from"]:
						if Nodes.get_child(arrow[type].x).get_child(arrow[type].y).node_texture == 0:
							if do_popup: on_create_error_popup("You have an arrow connected to a null node!")
							return true
			else:
				if do_popup: on_create_error_popup("Your beginning nodes are null!")
				return true
		"completable":
			if on_all_lines_exist() and on_all_lines_lead():
				var first_arrows: Array = NodeArrows.get_children().filter(func(x: Line2D): return x.from.y == map_size - 1)
				on_recursive_arrows(first_arrows.duplicate(), first_arrows)
				if first_arrows.size() != NodeArrows.get_children().size():
					if do_popup: on_create_error_popup("Your level is not completable!")
					return true
			else: 
				if do_popup: on_create_error_popup("Your level is not completable!")
				return true
					
		"empty-level":
			if NodeArrows.get_children().size() == 0 and do_popup: on_create_error_popup("Your level is empty")
	return false
	
func on_all_lines_lead() -> bool:
	return NodeArrows.get_children().all(func(x: Line2D): return NodeArrows.get_children().any(func(y: Line2D): return x.to == y.from or x.to.y == 0))
	
func on_all_lines_exist() -> bool:
	for i in range(1, map_size): 
		var is_exist: bool = NodeArrows.get_children().any(func(x: Line2D): return x.from.y == i)
		if !is_exist: return false
	return true
	
func on_recursive_arrows(arrows: Array, passed_arrows: Array) -> Array:
	var next_arrows: Array = []
	for arrow in arrows:
		for _arrow in NodeArrows.get_children():
			if arrow.to == _arrow.from:
				if _arrow not in passed_arrows: passed_arrows.append(_arrow)
				next_arrows.append(_arrow)
				
	if next_arrows:
		return on_recursive_arrows(next_arrows, passed_arrows)
	return passed_arrows
	
var _ErrorPopup: PackedScene = preload("res://scenes/screens/map_editor/error_popup.tscn")
func on_create_error_popup(text: String) -> void:
	var ErrorPopup: Control = _ErrorPopup.instantiate()
	ErrorPopup.get_node("Label").text = text
	add_child(ErrorPopup)

func _on_load_map_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_map_selected)
	add_child(FileLoader)
	
func on_map_selected(map_info: Dictionary) -> void:
	map_size = map_info.map_size
	for node_container in Nodes.get_children():
		for child in node_container.get_children(): child.queue_free()
	for arrow in NodeArrows.get_children(): arrow.queue_free()

	world_selected = map_info.world
	$SaveMenu/WorldSelector.default = map_info.world
	$SaveMenu/WorldSelector.set_grabber_position()
	$SaveMenu/EditFileName.set_text(map_info.iname, map_info.sname)
	
	on_change_map_size(0, false)
	for n in range(map_size): on_load_empty_node_row()
	for n in range(1, map_size): on_add_arrows_to_row(n)
	
	for node_info in map_info.nodes:
		on_node_texture_pressed(Nodes.get_child(node_info[1]).get_child(node_info[2]), node_info[0])

	await get_tree().create_timer(0.02).timeout
	on_map_selected_arrows(map_info)

const ARROW_DIFFERENT_CONVERSION: Dictionary = {
	"-1": 0,
	"0": 1,
	"1": 2,
}
func on_map_selected_arrows(map_info: Dictionary) -> void:
	for arrow_info in map_info.arrows:
		var NodeButton: Control = Nodes.get_child(arrow_info[0][0]).get_child(arrow_info[0][1])
		var arrow_type: int = arrow_info[0][0] - arrow_info[1][0]
		var converted_arrow: int = ARROW_DIFFERENT_CONVERSION[str(arrow_type)]
		on_arrow_node_pressed(NodeButton, NodeButton.get_node("NodeArrows").get_node(str(converted_arrow)), converted_arrow)

func _queue_free() -> void:
	_on_save_map_pressed(false)
