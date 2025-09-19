class_name SFXAction extends Action

var stream: AudioStream
func _init(_stream: AudioStream = null) -> void:
	super()
	stream = _stream
