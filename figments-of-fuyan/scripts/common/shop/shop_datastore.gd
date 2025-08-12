class_name ShopDatastore extends Resource

@export var id: int
@export var items: Array[ShopItemDatastore]
@export var background_icon: Texture2D
@export var merchant_icon_base: Texture2D
@export var merchant_frames: Array[Texture2D]
@export var background_main_color: Color

func getItems() -> Array[ShopItemDatastore]:
	return items

func getBackgroundMainColor() -> Color:
	return background_main_color

func getMerchantIconBase() -> Texture2D:
	return merchant_icon_base
	
func getMerchantFrames() -> Array[Texture2D]:
	return merchant_frames

func getBackgroundIcon() -> Texture2D:
	return background_icon
