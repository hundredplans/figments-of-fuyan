class_name CreateAreaAction extends Action

var area: AreaGD
func _init(_area: AreaGD = null) -> void:
	super()
	area = _area
	
func onPostAction() -> void:
	area.init_load.emit()
