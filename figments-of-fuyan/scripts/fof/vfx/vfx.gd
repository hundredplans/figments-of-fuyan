class_name VFXGD extends FofGD

var Model: Node3D
func onVFX() -> void:
	Model = info.scene.instantiate()
	add_child(Model)
	
func onSave() -> SavedDataVFX:
	return SavedDataVFX.new(info.id, false, public_id)
