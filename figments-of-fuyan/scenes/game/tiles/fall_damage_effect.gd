extends Node3D

@export var health_icon: Texture2D
@export var skull_icon: Texture2D

@onready var Icon: Sprite3D = %Icon
@onready var DamageLabel: Label3D = %DamageLabel

func setInfo(Tile: TileGD, PreviousTile: TileGD, damage: int) -> void:
	var SpectateObject: GameObjectGD = Game.getLevel().getSpectateObject()
	if SpectateObject != null and SpectateObject is CardGD:
		var Card: CardGD = SpectateObject
		Card.temp_fall_damage = 0
		global_position.y = Tile.getCardPositionBase().y
		DamageLabel.text = str(damage)
		Icon.texture = skull_icon if !Card.isCardSurviveFallDamage(damage) else health_icon
		global_rotation.y = (Game.getRelativeTileRotation(Tile, PreviousTile)) * (PI / 3) + (PI / 6)
