extends Control

const Y_OFFSET: int = 30
var GameState: Node
func on_load_minimap(_GameState) -> void:
	for child in $Nodes.get_children() + $NodeArrows.get_children(): child.queue_free()
	GameState = _GameState
	var new_arrows: Array = []
	var sprite_offset: int = (size.y - (10 * 2)) / (GameState.map_info.map_size + 1)
	for node_info in GameState.map_info.nodes + [[0, 1, GameState.map_info.map_size]]:
		var node_type: int = -1 if Vector2(node_info[1], node_info[2]) == GameState.map_progress else node_info[0]
		var NodeSprite := Sprite2D.new()
		NodeSprite.texture = load("res://scenes/screens/map_editor/node_types/" + str(node_type) + ".png")
		NodeSprite.scale = Vector2(0.5, 0.5)
		NodeSprite.position = Vector2((75 * node_info[1]) + 25, (sprite_offset * node_info[2]) + Y_OFFSET)
		$Nodes.add_child(NodeSprite)
		
		if node_info[2] == GameState.map_info.map_size - 1:
			new_arrows.append([[1, GameState.map_info.map_size], [node_info[1], node_info[2]]])
		
	for arrow_info in GameState.map_info.arrows + new_arrows:
		var Arrow := Line2D.new()
		Arrow.default_color = Helper.RED if Vector2(arrow_info[0][0], arrow_info[0][1]) == GameState.map_progress else Color("000000")
		$NodeArrows.add_child(Arrow)
		Arrow.width = 6
		Arrow.antialiased = true
		Arrow.add_point(Vector2((75 * arrow_info[1][0]) + 25, (sprite_offset * arrow_info[1][1]) + Y_OFFSET))
		Arrow.add_point(Vector2((75 * arrow_info[0][0]) + 25, (sprite_offset * arrow_info[0][1]) + Y_OFFSET))
