class_name ObjectInteractTilesGD
extends Resource

# The object id
@export var id: int
@export var name: String
# Tiles relative to the 'center' tile of the model
@export var tiles: Array[Vector4]
@export_multiline var description: String
@export var max_charges: int
@export var iobject_script: Script
# Decides whether when you click on unit mode box you have to select tiles or it triggers instantly
@export var select_tiles: bool
