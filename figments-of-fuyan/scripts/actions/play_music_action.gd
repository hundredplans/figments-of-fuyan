class_name PlayMusicAction extends Action

var stream: AudioStream
func _init(_stream: AudioStream = null) -> void:
	super()
	stream = _stream
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Audio.onPlayMusic(stream)
