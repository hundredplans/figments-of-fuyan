class_name SegmentNode extends Resource

var id: int
var segment_one: bool
var is_holy: bool

func _init(_id: int = 0, _segment_one: bool = false, _is_holy: bool = false) -> void:
	id = _id
	segment_one = _segment_one
	is_holy = _is_holy
