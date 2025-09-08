extends Control

@onready var ArtMiniBox: Control = %ArtMiniBox
@onready var TierLabel: Label = %TierLabel

func setInfo(data: SavedDataCard) -> void:
	ArtMiniBox.setInfo(data)
	TierLabel.text = "Tier %s" % Game.getTierString(data.tier)
	TierLabel.modulate = Game.getTierColor(data.tier)
