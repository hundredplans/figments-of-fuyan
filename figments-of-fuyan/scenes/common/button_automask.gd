class_name ButtonAutomask extends TextureButton

@export var highlight_on_hover: bool = true
func _ready() -> void:
	if texture_normal != null:
		setTexture(texture_normal.get_image())

func setTexture(img: Image) -> void:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	texture_click_mask = bitmap
	
	texture_normal = ImageTexture.create_from_image(img)

func _on_mouse_entered() -> void:
	if highlight_on_hover: modulate = Color(0.8, 0.8, 0.8)

func _on_mouse_exited() -> void:
	if highlight_on_hover: modulate = Color(1, 1, 1)
