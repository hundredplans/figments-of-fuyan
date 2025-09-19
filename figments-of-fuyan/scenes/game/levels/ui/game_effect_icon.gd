extends DefaultControl

var GameEffect: GameEffectGD
@onready var TurnsLabel: Label = %TurnsLabel
@onready var StrengthLabel: Label = %StrengthLabel
@onready var TxRect: TextureRect = %TxRect

func setInfo(_GameEffect: GameEffectGD) -> void:
	GameEffect = _GameEffect
	TxRect.texture = GameEffect.getIcon()
	
	var display_number: int = GameEffect.getDisplayNumber()
	var turns: int = GameEffect.getTurns()
	
	onUpdateDisplayNumber(display_number)
	onUpdateTurns(turns)
	
	GameEffect.update_display_number.connect(onUpdateDisplayNumber)
	GameEffect.update_turns.connect(onUpdateTurns)

func onUpdateDisplayNumber(display_number: int) -> void:
	StrengthLabel.text = str(display_number) if display_number != -1 else ""
	
func onUpdateTurns(turns: int) -> void:
	TurnsLabel.text = str(turns) if turns != -1 else ""

func getGameEffect() -> GameEffectGD:
	return GameEffect

func onMouseInUI(state: bool) -> void:
	super(state)
	Game.onMouseInUITooltip(state, GameEffect, self, true, true)
