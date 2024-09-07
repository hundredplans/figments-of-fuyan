class_name FofGD extends Node3D

var info: FofInfo
var groupsave: bool = true

#region Save / Load
func onSave() -> SavedData: return SavedData.new(info.id)
func onLoadData(_data: SavedData) -> void:
	add_to_group("FofGD")
func onClear() -> void: queue_free()
#endregion
