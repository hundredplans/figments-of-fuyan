class_name CreateVFXAction extends Action

var VFX: VFXGD
var destroy_after_delay: bool

func _init(_VFX: VFXGD, _destroy_after_delay: bool = true) -> void:
	super()
	VFX = _VFX
	destroy_after_delay = _destroy_after_delay
	
func onPreAction() -> void:
	setActionDelay(VFX.info.delay)
	
func onPostAction() -> void:
	VFX.onVFX()
	if destroy_after_delay:
		onPushAction(DestroyVFXAction.new(VFX))
