extends Control
signal type_filter_changed

func _on_pressed():
	if !has_node("Holder"):
		var holder: ColorRect = load("res://screens/deck_manager/type_filter_holder.tscn").instantiate()
		add_child(holder)

		for button in holder.get_children():
			button.self_modulate = Color(1,1,1,1)
			button.pressed.connect(_on_type_pressed.bind(button.name))
			
		for type in TempData.filter_settings.type_filter.applied:
			get_node("Holder/%s" % type).self_modulate = Color(1,1,1,0.5)
	else: get_node("Holder").queue_free()
			
func _on_type_pressed(type: String) -> void:
	
	if !TempData.filter_settings.type_filter.applied.has(type):
		TempData.filter_settings.type_filter.applied.append(type)
		get_node("Holder/%s" % type).self_modulate = Color(1,1,1,0.5)
	else:
		TempData.filter_settings.type_filter.applied.erase(type)
		get_node("Holder/%s" % type).self_modulate = Color(1,1,1,1)
		
	if TempData.filter_settings.type_filter.applied.size() > 0:
		TempData.filter_settings.type_filter.active = true
	else:
		TempData.filter_settings.type_filter.active = false
	
	type_filter_changed.emit()
