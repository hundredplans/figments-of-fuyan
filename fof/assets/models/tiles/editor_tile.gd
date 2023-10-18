extends Node
@export var Tile: Node3D
signal active_tile_change_state
signal exit_ones

var active_tile_possible_state: int = 2
var can_press: int = 0
var info: Dictionary = {
}

func load_tid(id: int) -> void:
	for child in Tile.get_children(): child.queue_free()
	if info.active_tile:
		var tile: Node3D = load("res://assets/models/tiles/" + Helper.id_to_tile(id, info.area) + ".glb").instantiate()
		Tile.add_child(tile)

func _on_detect_mouse_mouse_entered(blocker_rects: Array):
	if can_press != 4:
		can_press = 1
		if !(blocker_rects.filter(func(x: Rect2i): return x.has_point(get_viewport().get_mouse_position()))):
			if active_tile_possible_state == 2: load_tid(1)
			can_press = 2
		else: exit_ones.emit(info.position)
		
func _on_detect_mouse_mouse_exited():
	if can_press != 4:
		if can_press == 2:
			load_tid(info.tid)
			can_press = 0
	
func on_force_exit():
	if can_press != 4:
		if can_press == 2:
			load_tid(info.tid)
			can_press = 3
	
func _process(_delta: float) -> void:
	if can_press == 2 and Input.is_action_pressed(Helper.interact_button()):
		on_change_active_tile_state()
		
func on_change_active_tile_state() -> void:
	if active_tile_possible_state in [2, int(!info.active_tile)]:
		can_press = 2
		info.active_tile = !info.active_tile
		match info.active_tile:
			false: for child in Tile.get_children(): child.queue_free()
			true: load_tid(1)
		active_tile_change_state.emit(info.active_tile)
