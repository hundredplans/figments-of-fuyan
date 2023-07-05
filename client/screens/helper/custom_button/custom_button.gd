extends TextureButton

func _ready():
	var img := Image.new()
	img.load(texture_normal.resource_path)
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	texture_click_mask = bitmap
