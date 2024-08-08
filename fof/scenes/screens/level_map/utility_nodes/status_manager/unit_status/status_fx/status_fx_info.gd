class_name StatusFXInfoGD
extends Resource

# Corresponds to enum
@export var id: IDS
@export var texture: Texture2D
@export_multiline var tooltip: String
@export var status_fx_script: GDScript = preload("res://scenes/screens/level_map/utility_nodes/status_manager/unit_status/status_fx/scripts/status_fx_empty.gd")

enum IDS {STAGGER, DAZE, CHARMING_STANCE, PALM_FIREPLACE, HELPFUL_HELMET, PALMFESSOR_AURA, ARMOR,
	ANGRUS_RAMPAGE, COCUS_POCUS, NECKUS_WHEN_HEALED, SWINGUS_ON_HIT, SUGORI_KNIFE, BLIND, INVISIBLE,
	TRINKET, DESTRUCTIVE, MUTE}
