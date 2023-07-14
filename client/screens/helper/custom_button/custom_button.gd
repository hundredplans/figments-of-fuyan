extends TextureButton

func _ready():
	var img: Image = load("res://screens/GUI/back_arrow/back_arrow_image.png")
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	texture_click_mask = bitmap
