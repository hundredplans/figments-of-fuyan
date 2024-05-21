extends TextureButton

func _on_pressed(): queue_free()
func _ready(): global_position = get_viewport().get_mouse_position() - Vector2(10, 10)
