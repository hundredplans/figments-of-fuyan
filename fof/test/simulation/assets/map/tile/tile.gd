extends Node2D

signal move_unit
signal click_unit
signal destroy_unit
signal create_unit
signal visibility_update
signal disable_visible
signal solo_visible

signal change_tile_state
signal change_tile_item

signal unit_clicked

var active_editor_card: String
var solo_visibility: bool = false
var disable_visibility: bool = false
var always_visible: bool = false
const collision_tiles: Array = [1, 2, 13, 18, 19, 20]
var tile_item = ""
var old_tile_state: int = 0
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
				
		if Input.is_action_just_pressed("MouseMiddle"):
			if $In/Unit.texture: destroy_unit.emit(self)
			else: create_unit.emit(self)
				
	elif allow_change_anywhere:
		if Input.is_action_just_pressed("MouseMiddle"):
			if $In/Unit.texture:
				destroy_unit.emit(self, true)
			elif get_parent().get_parent().active_card:
				if get_parent().get_parent().active_card.team == 0 and get_parent().name == "Tiles":
					create_unit.emit(self, true)
				elif get_parent().get_parent().active_card.team == 1 and get_parent().name == "DualTiles":
					create_unit.emit(self, true)
		if Input.is_action_just_pressed("VisibleCheck"):
			if $In/Unit.texture != null:
				visibility_update.emit(self)
		if Input.is_action_just_pressed("DisableVisible"):
			disable_visible.emit(self)
		if Input.is_action_just_pressed("SoloVisible"):
			solo_visible.emit(self)

		if Input.is_action_just_pressed("ShiftRightClick"):
			match tile_state:
				0:
					tile_state = old_tile_state
				_:
					old_tile_state = tile_state
					tile_state = 0
			
			change_tile_state.emit([0, tile_state, tile_item, arrow_state], self)
			
		elif Input.is_action_just_pressed("RightClick"):
			change_tile_item.emit(self, tile_item)
			
		if Input.is_action_just_pressed("ShiftLeftClick"):
			match tile_state:
				2:
					tile_state = old_tile_state
				_:
					old_tile_state = tile_state
					tile_state = 2
					
			change_tile_state.emit([0, tile_state, tile_item, arrow_state], self)
			
		elif Input.is_action_just_pressed("LeftClick"):
			unit_clicked.emit(self)
			
func _on_area_2d_mouse_entered():
	allow_change = true
	
func _on_allow_change_in_select_level():
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
	
	if tile_item == "12.png" and get_parent().name == "Tiles": $In/TileItem.visible = false
	
	if tile_state in collision_tiles or tile_state == 3 and arrow_state in range(1, 11): 
		$Area2D.collision_mask = 0; $Area2D.collision_layer = 8
	else: $Area2D.collision_layer = 1; $Area2D.collision_mask = 1
	$In/Inside.texture = load("res://test/simulation/assets/map/tile/%s.png" % tile_state)
	if arrow_state != 0:
		$In/Arrow.texture = load("res://test/simulation/assets/map/arrows/%s.png" % arrow_state)
	else: $In/Arrow.texture = null
	
	if tile_item: $In/TileItem.texture = load("res://test/simulation/assets/trinkets/%s" % tile_item)
	else: $In/TileItem.texture = null

func _on_area_2d_mouse_exited():
	allow_change = false
	allow_change_anywhere = false

