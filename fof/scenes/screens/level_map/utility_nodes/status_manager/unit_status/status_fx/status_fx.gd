class_name StatusFXGD
extends Node

var StatusManager: StatusManagerGD

var info: StatusFXInfoGD
var HighlightUnit: UnitGD
var Unit: UnitGD
var AppliedBy: AppliedByGD

func setInfo(_Unit: UnitGD, _info: StatusFXInfoGD, _AppliedBy := AppliedByGD.new(), _HighlightUnit: UnitGD = null) -> void:
	Unit = _Unit
	info = _info
	AppliedBy = _AppliedBy
	HighlightUnit = _HighlightUnit
	Helper.onCreateChildReferences(self)
	
func setHighlightUnit(_Unit: UnitGD) -> void:
	HighlightUnit = _Unit

func getTooltip() -> String:
	return info.tooltip

func _onAfterSetInfo() -> void:
	StatusManager.onRefreshUnitStatus(Unit)

func onRemoveSelf() -> void: StatusManager.onRemoveStatusFX(self)
func getIcon() -> Texture2D: return info.texture
func onReady() -> void: pass
