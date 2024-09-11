extends PanelContainer

@onready var UnitTexture: TextureRect = %UnitTexture

func setInfo(card_info: CardInfo) -> void:
	UnitTexture.texture = ImageTexture.create_from_image(card_info.art_mini)
