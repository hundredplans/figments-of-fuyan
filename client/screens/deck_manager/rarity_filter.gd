extends Control

signal rarity_filter_changed

func _on_pressed():
	if !has_node("Holder"):
		var holder: ColorRect = load("res://screens/deck_manager/rarity_filter_holder.tscn").instantiate()
		add_child(holder)

		for button in holder.get_children():
			button.self_modulate = Color(1,1,1,1)
			button.pressed.connect(_on_rarity_pressed.bind(button.name))
			
		for rarity in TempData.filter_settings.rarity_filter.applied:
			get_node("Holder/%s" % rarity).self_modulate = Color(1,1,1,0.5)
	else: get_node("Holder").queue_free()
			
func _on_rarity_pressed(rarity: String) -> void:
	
	if !TempData.filter_settings.rarity_filter.applied.has(rarity):
		TempData.filter_settings.rarity_filter.applied.append(rarity)
		get_node("Holder/%s" % rarity).self_modulate = Color(1,1,1,0.5)
	else:
		TempData.filter_settings.rarity_filter.applied.erase(rarity)
		get_node("Holder/%s" % rarity).self_modulate = Color(1,1,1,1)
		
	if TempData.filter_settings.rarity_filter.applied.size() > 0:
		TempData.filter_settings.rarity_filter.active = true
	else:
		TempData.filter_settings.rarity_filter.active = false
	
	rarity_filter_changed.emit()
