extends Control

@export var elite_silhouette_texture: Texture2D

@onready var ArtMiniBox: Control = %ArtMiniBox
@onready var TierLabel: Label = %TierLabel

@export var elite_tier_label_color: Color

func setInfo(data: SavedDataCard) -> void:
	ArtMiniBox.setInfo(data)
	TierLabel.text = "Tier %s" % Game.getTierString(data.tier)
	TierLabel.modulate = Game.getTierColor(data.tier)

func setChief() -> void:
	ArtMiniBox.setSilhouette(elite_silhouette_texture, Game.getRarityColor(Game.Rarities.EXALT))
	TierLabel.text = "Tier ?"
	TierLabel.modulate = elite_tier_label_color
	
