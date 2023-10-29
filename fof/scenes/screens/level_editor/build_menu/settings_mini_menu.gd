extends Control
signal queued

func _ready() -> void:
	position = get_viewport().get_mouse_position() - $Background/PRTail.position - Vector2(-15, 50)
	for i in [["x", 1920], ["y", 1080]]:
		if position[i[0]] + size[i[0]] > i[1]: position[i[0]] -= (position[i[0]] + size[i[0]] - i[1]) + 5 
		elif position[i[0]] < 0: position[i[0]] = 0 + 5

func _enter_tree() -> void:
	for info in Settings.settings_info["Preferences"]:
		if $Settings.has_node(info[0]): $Settings.get_node(info[0]).default = info[1]
		
	for child in $Settings.get_children():
		child.item_selected.connect(Settings["set_" + child.name.to_lower()])
		child.item_selected.connect(Settings.update_settings_info.bind("Preferences", child.name))
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick") and !Geometry2D.is_point_in_polygon(get_viewport().get_mouse_position(), Array($DetectMouse/CollisionPolygon2D.polygon).map(func(x: Vector2): return x + global_position)) \
	or Input.is_action_just_pressed(Helper.interact_button()):
		_queued_free()

func _queued_free() -> void:
	queued.emit()
	queue_free()


