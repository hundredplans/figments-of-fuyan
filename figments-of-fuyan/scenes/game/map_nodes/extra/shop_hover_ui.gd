extends HoverUI

@onready var NameLabel: Label = %NameLabel
@onready var MerchantBaseSprite: Sprite2D = %MerchantBaseSprite
@onready var MerchantFrameSprite: Sprite2D = %MerchantFrameSprite

const SWAP_FRAME_TIME: float = 1.0
var shop: MapNodeGD
func setInfo(_shop: MapNodeGD) -> void:
	shop = _shop
	var shop_datastore: ShopDatastore = shop.getShopDatastore()
	NameLabel.text = shop.info.name
	NameLabel.modulate = shop_datastore.getBackgroundMainColor()
	MerchantBaseSprite.texture = shop_datastore.getMerchantIconBase()
	setMouseCenter(get_viewport().get_mouse_position())
	onFrameSprite()

func onFrameSprite(start: int = 1) -> void:
	MerchantFrameSprite.texture = shop.getShopDatastore().getMerchantFrames()[start - 1]
	await get_tree().create_timer(SWAP_FRAME_TIME).timeout
	onFrameSprite(1 if start == 2 else 2)
