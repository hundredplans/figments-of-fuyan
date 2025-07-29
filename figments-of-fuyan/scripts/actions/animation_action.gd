class_name AnimationAction extends Action

var GameObject: GameObjectGD
var animation_name: String
var play_backwards: bool

func _init(_GameObject: GameObjectGD = null, _animation_name: String = "", _play_backwards: bool = false) -> void:
	super()
	GameObject = _GameObject
	animation_name = _animation_name
	play_backwards
	
func onPreAction() -> void:
	if !GameObject.isLevelVisible(): onFailAction()
	
func onPostAction() -> void:
	GameObject.onPlayAnimation(animation_name, play_backwards)
	
	if action_delay > 0:
		var camera_change_back_action := CameraChangeAction.new(Game.getLevel().getSpectateObject())
		onForceAction(CameraChangeAction.new(GameObject))
		onPushAction(camera_change_back_action)
	
