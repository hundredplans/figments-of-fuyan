class_name PlayMusicAction extends Action

var stream: AudioStreamWAV
func _init(_stream: AudioStreamWAV) -> void:
	super()
	stream = _stream
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Audio.onPlayMusic(stream)
