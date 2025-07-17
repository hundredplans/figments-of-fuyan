extends Control

@export var TooltipItemPacked: PackedScene
@onready var MainContainer: Container = %MainContainer
var offset: Vector2

func setInfo(items: Array, _offset: Vector2, create_inner_tooltips: bool = false) -> void:
	offset = _offset
	var inner_tooltips: Array[InfoWithExtra] = []
	for FofObject in items:
		var TooltipItem: Control = TooltipItemPacked.instantiate()
		MainContainer.add_child(TooltipItem)
		TooltipItem.setInfo(FofObject)
			
		if create_inner_tooltips:
			inner_tooltips += TooltipItem.getTextInfos()
	
	for info_with_extra: InfoWithExtra in inner_tooltips:
		var TooltipItem: Control = TooltipItemPacked.instantiate()
		MainContainer.add_child(TooltipItem)
		TooltipItem.setInfo(info_with_extra)
		
func _process(_delta: float) -> void:
	setPosition()
	
func setPosition() -> void:
	global_position = get_viewport().get_mouse_position() + offset
	global_position.x = clamp(global_position.x, 10, (get_viewport().size.x - size.x - 10))
	global_position.y = clamp(global_position.y, 10, (get_viewport().size.y - size.y - 10))
