extends Node3D

signal champion_hovered
func setInfo(info: UnitInfoGD) -> void:
	var data := info.createData()
	var Unit: UnitGD = data.onLoad(self, info)
	Unit.setRayPickable(true)
	Unit.setScaleUniform(0.15)
	
	Unit.mouse_entered.connect(onUnitMouseEntered)
	Unit.mouse_exited.connect(onUnitMouseExited)
	
func onUnitMouseEntered(Unit: UnitGD) -> void:
	pass

func onUnitMouseExited(_Unit: UnitGD) -> void:
	pass
	
