extends Control

@onready var StatsLabel: FancyTextLabel = %StatsLabel
func setInfo(info: CardInfo, tier: int) -> void:
	var stats: StatsDatastore = info.getStats(tier)
	var text: String = str(stats.attack) + " ATT " + str(stats.health) + " HP " + str(stats.speed) + " SPD " + str(stats.energy) + " ENE"
	StatsLabel.setText(text)
