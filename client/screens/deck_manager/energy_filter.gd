extends Control

signal energy_filter_changed

func _on_energy_pressed(energy: int):
	if !TempData.filter_settings.energy_filter.applied.has(energy):
		TempData.filter_settings.energy_filter.applied.append(energy)
		get_node("Holder/%s" % str(energy)).self_modulate = Color(1,1,1,0.5)
	else:
		TempData.filter_settings.energy_filter.applied.erase(energy)
		get_node("Holder/%s" % str(energy)).self_modulate = Color(1,1,1,1)
		
	if TempData.filter_settings.energy_filter.applied.size() > 0:
		TempData.filter_settings.energy_filter.active = true
	else:
		TempData.filter_settings.energy_filter.active = false
	
	energy_filter_changed.emit()
 
func _on_pressed():
	if !has_node("Holder"):
		var holder: ColorRect = load("res://screens/deck_manager/energy_filter_holder.tscn").instantiate()
		add_child(holder)
		
		for button in holder.get_children():
			button.self_modulate = Color(1,1,1,1)
			button.pressed.connect(_on_energy_pressed.bind(button.name.to_int()))
			
		for energy in TempData.filter_settings.energy_filter.applied:
			get_node("Holder/%s" % energy).self_modulate = Color(1,1,1,0.5)
	else: get_node("Holder").queue_free()

