class_name IObjectActivatedAction extends Action
# Used for non abilities

var IObject: ObjectGD
var action: Action

func _init(_IObject: ObjectGD = null, _action: Action = null) -> void:
	super()
	IObject = _IObject
	action = _action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	IObject.onIObject(action)
