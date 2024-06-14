extends TextureRect
var info_fx: InfoFXGD
signal hover_unit_pressed

func setInfoFX(_info_fx: InfoFXGD) -> void:
	info_fx = _info_fx
	texture = info_fx.texture
	HoverUnit = info_fx.Unit

	if info_fx.charges > -1:
		var base_fx_label := preload("res://scenes/screens/level_map/utility_nodes/status_manager/unit_status/unit_fx/base_fx_label.tscn").instantiate()
		base_fx_label.text = str(info_fx.charges)
		add_child(base_fx_label)
	
const tooltip_delay: float = 0.4
var tooltip: Control

var HoverUnit: UnitGD
var mouse_state: bool = false
func _on_mouse_entered():
	if HoverUnit != null and !HoverUnit.is_dead: material = preload("res://scenes/screens/level_map/utility_nodes/status_manager/unit_status/unit_fx/info_fx_hover.tres")
	mouse_state = true
	if !info_fx.tooltip.is_empty():
		await get_tree().create_timer(tooltip_delay).timeout
		if mouse_state and tooltip == null:
			tooltip = preload("res://scenes/screens/level_map/utility_nodes/status_manager/unit_status/unit_fx/base_fx_tooltip.tscn").instantiate()
			tooltip.setTooltip(info_fx.tooltip, info_fx.charges)
			add_child(tooltip)
			tooltip.setPosition()

func _on_mouse_exited():
	if HoverUnit != null: material = null
	mouse_state = false
	if tooltip != null: tooltip.queue_free()

func _process(_delta: float) -> void:
	if tooltip != null: tooltip.setPosition()

func _input(_event: InputEvent) -> void:
	if mouse_state and HoverUnit != null and Input.is_action_just_pressed("LeftClick"):
		hover_unit_pressed.emit(HoverUnit)
