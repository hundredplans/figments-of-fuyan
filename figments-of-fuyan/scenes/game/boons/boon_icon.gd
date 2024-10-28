extends TextureRect

var Boon: BoonGD

@export var TooltipPacked: PackedScene
const TOOLTIP_DELAY: float = 0.3
const OFFSET := Vector2(10, -40)

func setInfo(_Boon: BoonGD) -> void:
	Boon = _Boon
	texture = Boon.getIcon()
	
var Tooltip: Control
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	if state:
		if Tooltip != null: Tooltip.queue_free()
		await get_tree().create_timer(TOOLTIP_DELAY).timeout
		Tooltip = TooltipPacked.instantiate()
		add_child(Tooltip)
		Tooltip.setInfo(Boon)
		Tooltip.global_position = get_viewport().get_mouse_position() + OFFSET
		
	elif Tooltip != null:
		Tooltip.queue_free()
		
func _process(_delta: float) -> void:
	if Tooltip != null:
		Tooltip.global_position = get_viewport().get_mouse_position() + OFFSET
