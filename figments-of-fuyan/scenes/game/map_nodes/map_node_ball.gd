extends MeshInstance3D

const BALL_SPEED: float = 1.0
const MAX_DISTANCE: float = 0.05
var direction: int = -1
var ActiveTween: Tween
var map_link: MapLink

func setInfo(_map_link: MapLink) -> void:
	map_link = _map_link
	position.y = -MAX_DISTANCE * 0.5
	onUpdate()
	
func onTweenChain() -> void:
	if map_link.is_finished: return
	direction *= -1
	
	ActiveTween = get_tree().create_tween()
	ActiveTween.tween_property(self, "position:y", MAX_DISTANCE * direction, BALL_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	ActiveTween.finished.connect(onTweenChain)
		
func onUpdate() -> void:
	if map_link.is_finished:
		if ActiveTween: ActiveTween.kill()
		position.y = 0
