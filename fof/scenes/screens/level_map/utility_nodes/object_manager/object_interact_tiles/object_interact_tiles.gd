class_name ObjectInteractTilesGD
extends Resource

# The object id
@export var id: int
@export var name: String
# Tiles relative to the 'center' tile of the model
@export var tiles: Array[Vector4]
@export var abilities: Array[IObjectAbilityInfoGD]
@export var iobject_script: Script
# Decides whether when you click on unit mode box you have to select tiles or it triggers instantly
