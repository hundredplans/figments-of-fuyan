extends Node2D

enum {TILE_NULL, TILE_VOID, TILE_TREE, TILE_WATER, TILE_SPAWN_ALLY, TILE_SPAWN_ENEMY, TILE_SPAWN_ITEM}
enum {NOTHING_ARROW, ARROW_TOPLEFT, ARROW_TOPRIGHT, ARROW_BOTLEFT, ARROW_BOTRIGHT, ARROW_LEFT, ARROW_RIGHT}
var tile_item = ""
var tile_state = TILE_NULL
var tile_position := Vector2.ZERO
var arrow_state = NOTHING_ARROW

func _on_area_2d_mouse_entered():
#	var label := Label.new()
#	$PositionDisplay.add_child(label)
#	label.text = "%s, %s" % [tile_position.x, tile_position.y]
#	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
#	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if Input.is_action_pressed("LeftClick"):
		_on_inside_pressed()
	
func _on_area_2d_mouse_exited():
	for child in $PositionDisplay.get_children(): child.queue_free()

func _on_inside_pressed():
	tile_state = get_parent().get_parent().active_tile_state
	arrow_state = get_parent().get_parent().active_arrow_state
	tile_item = get_parent().get_parent().active_tile_item
	$Inside.texture_normal = load("res://assets/map/tile/%s.png" % tile_state)
	if arrow_state != 0:
		$Arrow.texture = load("res://assets/map/arrows/%s.png" % arrow_state)
	else: $Arrow.texture = null
	
	if tile_item: $TileItem.texture = load("res://assets/sprites/%s" % tile_item)
	else: $TileItem.texture = null
