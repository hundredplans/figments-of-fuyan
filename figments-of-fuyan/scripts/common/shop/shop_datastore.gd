class_name ShopDatastore extends EncounterDatastore

@export var items: Array[ShopItemDatastore]
@export var merchant_buy_frame: Texture2D

const SHOP_DRAG_ZONE_MATERIAL_PATH: String = "res://resources/materials/ui/shop_drag_zone.tres"

func getItems() -> Array[ShopItemDatastore]:
	return items

func getBuyFrame() -> Texture2D:
	return merchant_buy_frame

func getDragZoneName() -> String:
	return "Sell  Zone"
	
func getDragZoneMaterial() -> ShaderMaterial:
	return load(SHOP_DRAG_ZONE_MATERIAL_PATH)

func getDragZoneLabelColor() -> Color:
	return Color("#00ff00")
