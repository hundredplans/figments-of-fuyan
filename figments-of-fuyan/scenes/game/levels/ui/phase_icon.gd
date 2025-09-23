extends TextureRect

const SWAP_SPEED: float = 0.5
@export var start_phase_icon: Texture2D
@export var player_phase_icon: Texture2D
@export var ai_phase_icon: Texture2D
@export var neutral_phase_icon: Texture2D

var current_phase: Game.Phases
func setPhase(phase: Game.Phases) -> void:
	if phase == current_phase: return
	current_phase = phase
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale:y", 0, SWAP_SPEED)
	
	await tween.finished
	
	texture = getPhaseTexture()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale:y", 1, SWAP_SPEED)

func getPhaseTexture() -> Texture2D:
	var next_icon: Texture2D
	match current_phase:
		Game.Phases.START: next_icon = start_phase_icon
		Game.Phases.PLAYER: next_icon = player_phase_icon
		Game.Phases.AI: next_icon = ai_phase_icon
		Game.Phases.NEUTRAL: next_icon = neutral_phase_icon
	return next_icon
