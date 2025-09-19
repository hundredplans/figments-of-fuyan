extends Control

@export var TooltipItemPacked: PackedScene
var offset: Vector2
var flip_side: bool

func setInfo(items: Array, _offset: Vector2, create_inner_tooltips: bool = false, _flip_side: bool = false) -> void:
	flip_side = _flip_side
	var inner_tooltips: Array[InfoWithTier] = []
	for FofObject in items:
		var TooltipItem: Control = TooltipItemPacked.instantiate()
		add_child(TooltipItem)
		TooltipItem.setInfo(FofObject)
			
		if create_inner_tooltips:
			inner_tooltips += TooltipItem.getTextInfos()
	
	for info_with_extra: InfoWithTier in inner_tooltips:
		var TooltipItem: Control = TooltipItemPacked.instantiate()
		add_child(TooltipItem)
		TooltipItem.setInfo(info_with_extra)
		
	offset = _offset
	call_deferred("setInfoDeferred")
	
func setInfoDeferred() -> void:
	if flip_side:
		offset.x *= -1
		offset.x -= custom_minimum_size.x
	setPosition()
		
func _process(_delta: float) -> void:
	setPosition()
	
func setPosition() -> void:
	global_position = get_viewport().get_mouse_position() + offset
	global_position.y -= (size.y / 2.0)
	
	if !flip_side:
		global_position.x = clamp(global_position.x, 10, (get_viewport().size.x - size.x - 10))
		global_position.y = clamp(global_position.y, 10, (get_viewport().size.y - size.y - 10))
	else:
		global_position.x = clamp(global_position.x, 10, (get_viewport().size.x - 10))
		global_position.y = clamp(global_position.y, 10, (get_viewport().size.y - 10))
		
