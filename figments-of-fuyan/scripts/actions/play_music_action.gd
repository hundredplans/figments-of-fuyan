class_name PlayMusicAction extends Action

var enum_value:  int
func _init(_enum_value: int) -> void:
	super()
	enum_value = _enum_value
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Audio.onPlayMusic(enum_value)
