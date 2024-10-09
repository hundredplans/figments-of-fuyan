extends Node3D

const COLUMNS: int = 5
const SPACING: float = 0.5
func _ready() -> void:
	position.x = -((COLUMNS / 4.0) - (SPACING / 2.0))
	onSortNodes()

func _on_child_entered_tree(node: Node) -> void:
	node.no_depth_test = depth_test_state
	onSortNodes()

func _on_child_exiting_tree(node: Node) -> void:
	onSortNodes(node)

func onSortNodes(exiting_node: Node = null) -> void:
	var nodes: Array = get_children().filter(func(x: Sprite3D): return x != exiting_node)
	var count: int = nodes.size()
	@warning_ignore("integer_division")
	var rows: int = (count + COLUMNS - 1) / COLUMNS
	for row in range(rows):
		for col in range(COLUMNS):
			var index: int = row * COLUMNS + col
			if index >= count: return
			nodes[index].position = Vector3(col * SPACING, row * SPACING, 0)
	
var depth_test_state: bool
func setDepthTest(state: bool) -> void:
	depth_test_state = state
	for child in get_children():
		child.no_depth_test = depth_test_state
