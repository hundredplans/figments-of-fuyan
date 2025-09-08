class_name ShopScreen extends EncounterSubscreen

@onready var EncounterMainUI: Control = %EncounterMainUI
@onready var PurchasableManager: Control = %PurchasableManager

@export var PurchasableCardPacked: PackedScene
@export var PurchasableBoonPacked: PackedScene
@export var PurchasableToolPacked: PackedScene

const TRANSFORM_WAIT_PRESSED_TIME: float = 1.5
const CARD_FLIP_TIME: float = 0.25

func setInfo(_map_node: MapNodeGD) -> void:
	super(_map_node)
	var base: Texture2D = map_node.getShopDatastore().getBaseSprite()
	var frames: Array[Texture2D] = map_node.getShopDatastore().getFrames()
	EncounterMainUI.setInfo(base, frames)
	onCreatePurchasables()
	
func onCreatePurchasables() -> void:
	for price_datastore: PriceDatastore in map_node.getItems():
		var data: SavedData = price_datastore.getData()
		var PurchasableScene: Control = getPurchasableFromType(data.getInfoType()).instantiate()
		PurchasableManager.add_child(PurchasableScene)
		PurchasableScene.setInfo(price_datastore)
		PurchasableScene.pressed.connect(onItemPressed)

func getPurchasableFromType(type: GDScript) -> PackedScene:
	if type == BoonInfo: return PurchasableBoonPacked
	elif type == CardInfo: return PurchasableCardPacked
	elif type == ToolInfo: return PurchasableToolPacked
	return null

func getMinimapFadeNodes() -> Array:
	return [PurchasableManager, EncounterMainUI]
	
func getStashFadeNodes() -> Array:
	return [PurchasableManager, EncounterMainUI]
		
func onItemPressed(price_datastore: PriceDatastore) -> void:
	map_node.onItemBought(price_datastore)
	EncounterMainUI.setExtraFrame(map_node.getShopDatastore().getBuyFrame())

func _on_encounter_main_ui_pressed() -> void:
	create_stash_screen.emit(null)
