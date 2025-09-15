extends Control

@onready var ArtMiniBox: Control = %ArtMiniBox
@onready var AttackLabel: Label = %AttackLabel
@onready var HealthLabel: Label = %HealthLabel
@onready var SpeedLabel: Label = %SpeedLabel

@onready var VisibleTxRect: TextureRect = %VisibleTxRect

var Card: CardGD
var is_spectated: bool

func setInfo(_Card: CardGD) -> void:
	Card = _Card
	Card.update_stat.connect(onUpdateStat)
	Card.update_level_visible.connect(onUpdateLevelVisible)
	onUpdateStat(Game.Stats.ATTACK, Card.getAttack())
	onUpdateStat(Game.Stats.HEALTH, Card.getHealth())
	onUpdateStat(Game.Stats.SPEED, Card.getSpeed())
	onUpdateLevelVisible(Card.isLevelVisible())
	
	ArtMiniBox.setInfo(Card.onSave(), true)

func onUpdateStat(type: Game.Stats, value: int) -> void:
	if type not in [Game.Stats.ATTACK, Game.Stats.HEALTH, Game.Stats.SPEED]: return
	
	var label: Label
	match type:
		Game.Stats.ATTACK: label = AttackLabel
		Game.Stats.HEALTH: label = HealthLabel
		Game.Stats.SPEED: label = SpeedLabel
	
	label.text = str(value)
	
func onUpdateLevelVisible(_is_level_visible: bool) -> void:
	onUpdateVisible()
	
func onUpdateVisible() -> void:
	visible = Card.isLevelVisible() and !is_spectated

func setSpectated(_is_spectated: bool) -> void:
	is_spectated = _is_spectated
	onUpdateVisible()

func getCard() -> CardGD: return Card
