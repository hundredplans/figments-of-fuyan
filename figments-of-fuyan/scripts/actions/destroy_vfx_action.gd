class_name DestroyVFXAction extends Action

var VFX: VFXGD
func _init(_VFX: VFXGD = null) -> void:
	super()
	VFX = _VFX
	
func onPreAction() -> void:
	if VFX == null or VFX.is_queued_for_deletion(): onFailAction()
	
func onPostAction() -> void:
	VFX.visible = false
	VFX.onClear()
