extends Control

@export var up_arrow_one: Texture2D
@export var up_arrow_two: Texture2D
@export var up_arrow_three: Texture2D

@export var down_arrow_one: Texture2D
@export var down_arrow_two: Texture2D
@export var down_arrow_three: Texture2D

@export var up_arrow_color: Color
@export var down_arrow_color: Color

@onready var AttackLabel: Label = %AttackLabel
@onready var HealthLabel: Label = %HealthLabel
@onready var SpeedLabel: Label = %SpeedLabel

@export var AttackArrowLabel: Label
@export var HealthArrowLabel: Label
@export var SpeedArrowLabel: Label

@export var AttackArrowTx: TextureRect
@export var HealthArrowTx: TextureRect
@export var SpeedArrowTx: TextureRect

var Card: CardGD

func getAttackLabel() -> Label: return AttackLabel
func getHealthLabel() -> Label: return HealthLabel
func getSpeedLabel() -> Label: return SpeedLabel

func setCard(_Card: CardGD) -> void:
	Card = _Card
	Card.update_delayed_stats.emit(onUpdateDelayedStats)
	onUpdateDelayedStats()

func onUpdateDelayedStats() -> void:
	var stats: Dictionary[Game.Stats, int] = {Game.Stats.ATTACK: 0, Game.Stats.MAX_HEALTH: 0, Game.Stats.MAX_SPEED: 0}
	for delayed: Variant in Card.delayed_stats:
		for i in range(delayed.getSize()):
			var type: Game.Stats = delayed.getType(i)
			if type not in [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.MAX_SPEED]: continue
			stats[delayed.getType(i)] += delayed.getValue(i)
			
	for stat: Game.Stats in stats:
		setDelayedStat(stat, stats[stat])
		
func setDelayedStat(type: Game.Stats, value: int) -> void:
	var texture: Texture2D
	match value:
		1: texture = up_arrow_one
		2: texture = up_arrow_two
		3: texture = up_arrow_three
		-1: texture = down_arrow_one
		-2: texture = down_arrow_two
		-3: texture = down_arrow_three
		_:
			if value > 3: texture = up_arrow_three
			elif value < -3: texture = down_arrow_three
			else: texture = null
	
	var TxRect: TextureRect
	var label: Label
	match type:
		Game.Stats.ATTACK: TxRect = AttackArrowTx; label = AttackArrowLabel
		Game.Stats.MAX_HEALTH: TxRect = HealthArrowTx; label = HealthArrowLabel
		Game.Stats.MAX_SPEED: TxRect = SpeedArrowTx; label = SpeedArrowLabel
	
	TxRect.texture = texture
	label.text = (str(value) if value < 0 else "+%s" % [value]) if value != 0 else ""
	
	var color: Color = up_arrow_color if value > 0 else down_arrow_color
	TxRect.modulate = color
	label.modulate = color
	
