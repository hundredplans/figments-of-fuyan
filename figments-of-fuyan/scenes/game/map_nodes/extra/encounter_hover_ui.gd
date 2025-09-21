extends HoverUI

@onready var NameLabel: Label = %NameLabel

@onready var TypeLabel: Label = %TypeLabel
@onready var TypeTx: TextureRect = %TypeTx

@onready var EncounterIconTx: TextureRect = %EncounterIconTx

@export var ENCOUNTER_TEXTURE: Texture2D
@export var SHOP_TEXTURE: Texture2D

@export var ENC_COLOR: Color
@export var SHOP_COLOR: Color

const TIMER_TIME: float = 1.5

func setInfo(map_node: MapNodeGD) -> void:
	var enc_datastore: EncounterDatastore = map_node.getEncounterDatastore()
	NameLabel.text = map_node.info.name
	NameLabel.modulate = enc_datastore.getBackgroundMainColor()
	setMouseCenter(get_viewport().get_mouse_position())
	
	var type_text: String = "Encounter"
	var type_tx: Texture2D = ENCOUNTER_TEXTURE
	var type_color: Color = ENC_COLOR
	if enc_datastore is ShopDatastore:
		type_text = "Shop"
		type_tx = SHOP_TEXTURE
		type_color = SHOP_COLOR
		
	TypeLabel.text = type_text
	TypeTx.texture = type_tx
	TypeLabel.modulate = type_color
	EncounterIconTx.texture = enc_datastore.getBackgroundIcon()
	onTimer()

func setMouseCenter(mouse_position: Vector2) -> void:
	global_position = mouse_position - pivot_offset
	
func onTimer() -> void:
	await get_tree().create_timer(TIMER_TIME).timeout
	TypeTx.flip_h = !TypeTx.flip_h
	onTimer()
