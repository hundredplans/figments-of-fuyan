class_name IObjectDamagedAction extends Action

var IObject: IObjectGD
var damage_action: DamageAction

func _init(_IObject: IObjectGD = null, _damage_action: DamageAction = null) -> void:
	super()
	IObject = _IObject
	damage_action = _damage_action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	IObject.onIObjectDamaged(damage_action)

func getDelay() -> float:
	return super()
