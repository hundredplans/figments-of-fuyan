extends Control

@onready var AttackLabel: Label = %AttackLabel
@onready var HealthLabel: Label = %HealthLabel
@onready var SpeedLabel: Label = %SpeedLabel

func setInfo(info: CardInfo, tier: int) -> void:
	var stats: StatsDatastore = info.getStats(tier)
	
	AttackLabel.text = str(stats.attack)
	HealthLabel.text = str(stats.health)
	SpeedLabel.text = str(stats.speed)
