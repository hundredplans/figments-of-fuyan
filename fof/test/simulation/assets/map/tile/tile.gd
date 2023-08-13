extends Node2D

signal move_unit
signal click_unit
signal destroy_unit
signal create_unit
signal visibility_update

var always_visible: bool = false
const collision_tiles: Array = [1, 2, 13]
var tile_item = ""
var tile_state: int = 0
var arrow_state: int = 0

var tile_position := Vector2.ZERO
var allow_change: bool = false
var allow_change_anywhere: bool = false
var in_level: bool = false

func _process(_delta: float) -> void:
	if allow_change:
		if Input.is_action_pressed("LeftClick") or Input.is_action_just_pressed("LeftClick"):
			if self not in get_parent().get_parent().touched_tiles:
				get_parent().get_parent().touched_tiles.append(self)
				_on_level_editor_inside_pressed()
			
	if allow_change_anywhere:
		if Input.is_action_just_pressed("RightClick"):
			if $In/TileItem.texture:
				$In/TileItem.texture = null
			
			elif $In/TileItem.texture == null:
				if tile_item: $In/TileItem.texture = load("res://test/simulation/assets/sprites/%s" % tile_item)
				else: $In/TileItem.texture = null
				
		if Input.is_action_just_pressed("MouseMiddle"):
			if $In/Unit.texture:
				destroy_unit.emit(self, true)
			elif get_parent().get_parent().active_card:
				create_unit.emit(self, true)
				
		if Input.is_action_just_pressed("LeftClick"):
			match get_parent().get_parent().unit_selected:
				[]: click_unit.emit(self)
				_: move_unit.emit(self)
				
		if Input.is_action_just_pressed("VisibleCheck"):
			if $In/Unit.texture != null:
				always_visible = !always_visible
				visibility_update.emit(self)

func _on_area_2d_mouse_entered():
	allow_change = true
	
func _on_allow_change_in_level_editor():
	allow_change_anywhere = true

func _on_level_editor_inside_pressed():
	if get_parent().get_parent().nono_zone == 0 and !get_parent().get_parent().no_paint:
		tile_state = get_parent().get_parent().active_tile_state
		arrow_state = get_parent().get_parent().active_arrow_state
		tile_item = get_parent().get_parent().active_tile_item
		
		$In/Inside.texture = load("res://test/simulation/assets/map/tile/%s.png" % tile_state)
		if arrow_state != 0:
			$In/Arrow.texture = load("res://test/simulation/assets/map/arrows/%s.png" % arrow_state)
			get_parent().get_parent().active_arrow_state = 0
		else: $In/Arrow.texture = null
		
		if tile_item: 
			$In/TileItem.texture = load("res://test/simulation/assets/trinkets/%s" % tile_item)
			get_parent().get_parent()._on_clear_selection_pressed()
		else: $In/TileItem.texture = null

func _on_simulation_inside_pressed(tile_info: Array):
	tile_state = tile_info[1]
	tile_item = tile_info[2]
	arrow_state = tile_info[3]
	
	if tile_state in collision_tiles: $Area2D.collision_mask = 0; $Area2D.collision_layer = 8
	else: $Area2D.collision_layer = 1
	$In/Inside.texture = load("res://test/simulation/assets/map/tile/%s.png" % tile_state)
	if arrow_state != 0:
		$In/Arrow.texture = load("res://test/simulation/assets/map/arrows/%s.png" % arrow_state)
	else: $In/Arrow.texture = null
	
	if tile_item: $In/TileItem.texture = load("res://test/simulation/assets/trinkets/%s" % tile_item)
	else: $In/TileItem.texture = null

func _on_area_2d_mouse_exited():
	allow_change = false
	allow_change_anywhere = false

