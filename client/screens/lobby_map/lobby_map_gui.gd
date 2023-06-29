extends Control
var on_item: int = 0
var can_glow: bool = true
signal lobby_item_selected

func _ready():
	create_lobby_glows_outlines_area()

func create_lobby_glows_outlines_area():
	for child in $LobbyGlows.get_children():
		
		if child is Sprite2D:
			child.visible = false
		
		if child is Node2D and child.get_children().size():
			var current_line_points: PackedVector2Array = []
			var toddler_color: Color 
			for toddler in child.get_children():
				if toddler as Line2D:
					current_line_points += toddler.points
					toddler.width = 5
					toddler_color = toddler.default_color
					toddler.visible = false
					
			create_lobby_outline_area_polygon(child, toddler_color, current_line_points)
				
func create_lobby_outline_area_polygon(child: Node2D, toddler_color: Color, current_line_points: PackedVector2Array) -> void:
	
	var area := Area2D.new()
	var polygon := Polygon2D.new()
	var cpolygon := CollisionPolygon2D.new()
	
	child.add_child(area)
	child.add_child(polygon)
	area.add_child(cpolygon)
	
	polygon.visible = false
	
	current_line_points[current_line_points.size() - 1] = current_line_points[0]
	cpolygon.polygon = current_line_points
	polygon.polygon = current_line_points
	polygon.color = toddler_color
	polygon.color.a = 0.155
	
	area.mouse_entered.connect(on_lobby_item_mouse_entered.bind(child.name.to_int()))
	area.mouse_exited.connect(on_lobby_item_mouse_exited.bind(child.name.to_int()))
	
func on_lobby_item_mouse_entered(item_id: int):
	if can_glow:
		on_set_lobby_glow_item_visibility(true, item_id)
		on_item = item_id
func on_lobby_item_mouse_exited(item_id: int):
	if can_glow:
		on_set_lobby_glow_item_visibility(false, item_id)
		on_item = 0
	
func on_set_lobby_glow_item_visibility(state: bool, item_id: int):
	for child in $LobbyGlows.get_node("%s" % item_id).get_children():
		if child is Line2D or child is Polygon2D: child.visible = state
		
func _process(_delta: float):
	if on_item and Input.is_action_just_pressed("InputA"): 
		var local_item: int = on_item
		on_lobby_item_mouse_exited(on_item)
		lobby_item_selected.emit(local_item)
		can_glow = false

func on_lobby_camera_travel_main_menu_finished(): 
	can_glow = true
