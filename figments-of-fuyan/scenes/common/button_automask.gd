class_name ButtonAutomask extends TextureButton

func _ready() -> void:
	if texture_normal != null:
		setTexture(texture_normal.get_image())

func setTexture(img: Image) -> void:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	texture_click_mask = bitmap
	
	texture_normal = ImageTexture.create_from_image(img)
