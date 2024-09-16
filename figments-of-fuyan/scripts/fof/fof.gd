class_name FofGD extends Node3D

signal push_action
signal append_action

var info: FofInfo
var groupsave: bool = true

#region Save / Load
func onSave() -> SavedData: return SavedData.new(info.id)
func onLoadData(_data: SavedData) -> void:
	add_to_group("FofGD")
func onClear() -> void: queue_free()

func onPushAction(action: Action) -> void:
	action.owner = self
	push_action.emit(action)
	
func onAppendAction(action: Action) -> void:
	action.owner = self
	append_action.emit(action)

#endregion
