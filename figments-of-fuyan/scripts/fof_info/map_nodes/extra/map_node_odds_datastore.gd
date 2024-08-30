class_name MapNodeOddsDatastore extends Resource

@export var progress: int

@export_group("Add to 100%")
@export_range(0, 100, 0.1) var regular_fight: float
@export_range(0, 100, 0.1) var encounter: float
@export_range(0, 100, 0.1) var shop: float
@export_group("")

@export_group("Generation Upgrades")
@export_range(0, 100, 0.1) var upgrade_regular_fight: float
@export_group("")
