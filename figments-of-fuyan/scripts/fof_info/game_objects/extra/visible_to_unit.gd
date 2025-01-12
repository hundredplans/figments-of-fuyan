class_name VisibleToUnit extends Resource

@export var direct: bool # Visible via a ray
func onSave() -> void:
	pass
	
func onLoad() -> void:
	pass
	
func isVisibleToUnit() -> bool:
	return false
	
func setDirect(_direct: bool) -> void:
	direct = _direct
