extends TextureRect

const SWAP_SPEED: float = 0.5
@export var start_phase_icon: Texture2D
@export var hand_phase_icon: Texture2D
@export var player_phase_icon: Texture2D
@export var ai_phase_icon: Texture2D
@export var neutral_phase_icon: Texture2D

func setPhase(phase: Game.Phases) -> void:
	var next_icon: Texture2D
	match phase:
		Game.Phases.START: next_icon = start_phase_icon
		Game.Phases.HAND: next_icon = hand_phase_icon
		Game.Phases.PLAYER: next_icon = player_phase_icon
		Game.Phases.AI: next_icon = ai_phase_icon
		Game.Phases.NEUTRAL: next_icon = neutral_phase_icon
		
	if next_icon != texture:
		var tween := get_tree().create_tween()
		tween.tween_property(self, "scale:y", 0, SWAP_SPEED)
		
		await tween.finished
		
		texture = next_icon
		tween = get_tree().create_tween()
		tween.tween_property(self, "scale:y", 1, SWAP_SPEED)
