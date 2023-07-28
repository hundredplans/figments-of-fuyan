extends Node2D

signal destroy_unit
signal create_unit
enum {TILE_NULL, TILE_VOID, TILE_TREE, TILE_WATER, TILE_SPAWN_ALLY, TILE_SPAWN_ENEMY, TILE_SPAWN_ITEM}
enum {NOTHING_ARROW, ARROW_TOPLEFT, ARROW_TOPRIGHT, ARROW_BOTLEFT, ARROW_BOTRIGHT, ARROW_LEFT, ARROW_RIGHT}
var tile_item = ""
var tile_state = TILE_NULL
var tile_position := Vector2.ZERO
var arrow_state = NOTHING_ARROW
var allow_change: bool = false
var allow_change_anywhere: bool = false
var in_level: bool = false

func _process(_delta: float) -> void:
	if allow_change:
		if Input.is_action_pressed("LeftClick") or Input.is_action_just_pressed("LeftClick"):
			_on_level_editor_inside_pressed()
			
	if allow_change_anywhere:
		if Input.is_action_just_pressed("RightClick"):
			if $TileItem.texture:
				$TileItem.texture = null
			
			elif $TileItem.texture == null:
				if tile_item: $TileItem.texture = load("res://assets/sprites/%s" % tile_item)
				else: $TileItem.texture = null
				
		if Input.is_action_just_pressed("MouseMiddle"):
			if $Unit.texture:
				destroy_unit.emit(self)
			elif get_parent().get_parent().active_card:
				create_unit.emit(self)
			

func _on_area_2d_mouse_entered():
	allow_change = true
	
func _on_allow_change_in_level_editor():
	allow_change_anywhere = true

func _on_level_editor_inside_pressed():
	tile_state = get_parent().get_parent().active_tile_state
	arrow_state = get_parent().get_parent().active_arrow_state
	tile_item = get_parent().get_parent().active_tile_item
	$Inside.texture = load("res://assets/map/tile/%s.png" % tile_state)
	if arrow_state != 0:
		$Arrow.texture = load("res://assets/map/arrows/%s.png" % arrow_state)
	else: $Arrow.texture = null
	
	if tile_item: $TileItem.texture = load("res://assets/sprites/%s" % tile_item)
	else: $TileItem.texture = null

func _on_simulation_inside_pressed(tile_info: Array):
	tile_state = tile_info[1]
	tile_item = tile_info[2]
	arrow_state = tile_info[3]
	
	if tile_state == TILE_TREE: $Area2D.collision_layer = 4
	else: $Area2D.collision_layer = 1
	print($Area2D.collision_layer)
	$Inside.texture = load("res://assets/map/tile/%s.png" % tile_state)
	if arrow_state != 0:
		$Arrow.texture = load("res://assets/map/arrows/%s.png" % arrow_state)
	else: $Arrow.texture = null
	
	if tile_item: $TileItem.texture = load("res://assets/sprites/%s" % tile_item)
	else: $TileItem.texture = null

func _on_area_2d_mouse_exited():
	allow_change = false
	allow_change_anywhere = false
