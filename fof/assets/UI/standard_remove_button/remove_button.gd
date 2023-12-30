extends TextureButton

func _ready():
	Helper.create_button_clickmask(self)

func _on_mouse_entered(): modulate = Helper.DARK_GREY
func _on_mouse_exited(): modulate = Helper.BASE
