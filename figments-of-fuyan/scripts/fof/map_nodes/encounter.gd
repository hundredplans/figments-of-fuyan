class_name EncounterGD extends MapNodeGD

const OZHARS_BAZAAR_DATASTORE_PATH: String = "res://resources/datastore/encounters/encounter_datastore/ozhars_bazaar_datastore.tres"
const GENERAL_SHOP_DATASTORE_PATH: String = "res://resources/datastore/encounters/encounter_datastore/general_shop_datastore.tres"
const JUNK_MAN_DATASTORE_PATH: String = "res://resources/datastore/encounters/encounter_datastore/junk_man_datastore.tres"
const SMITH_DATASTORE_PATH: String = "res://resources/datastore/encounters/encounter_datastore/smith_datastore.tres"

func onSave() -> SavedDataMapNode:
	return SavedDataEncounter.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save)

func onFofInit() -> void:
	super()
	onLoadEncounterDatastore()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	onLoadEncounterDatastore() 

var encounter_datastore: EncounterDatastore
func getEncounterDatastore() -> EncounterDatastore:
	return encounter_datastore

func onLoadEncounterDatastore() -> void:
	if encounter_datastore != null: return
	var path: String
	match info.id:
		5: path = OZHARS_BAZAAR_DATASTORE_PATH
		6: path = GENERAL_SHOP_DATASTORE_PATH
		11: path = SMITH_DATASTORE_PATH
		12: path = JUNK_MAN_DATASTORE_PATH
		_: path = GENERAL_SHOP_DATASTORE_PATH
	encounter_datastore = load(path)

func onEntered() -> void:
	super()
	onCreateScreen()

func onUpdateHovered() -> void:
	if is_queued_for_deletion(): return
	var state: bool = getHoveredState()
	if state:
		if HoverUI != null: HoverUI.queue_free()
		HoverUI = load(getHoverUIPath()).instantiate()
	super()
	
func getHoverUIPath() -> String:
	return info.ENCOUNTER_HOVER_UI

func isDragZone() -> bool: return true

func getStashItemPrice(item: FofGD) -> int:
	return int(float(Game.getPriceForItem(item)) * Game.SELL_MULT)

func isStashDragItem() -> bool:
	return true
