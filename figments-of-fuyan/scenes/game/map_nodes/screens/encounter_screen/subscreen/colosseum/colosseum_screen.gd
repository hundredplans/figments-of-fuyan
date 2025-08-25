extends EncounterSubscreen
@onready var EncounterMainUI: Control = %EncounterMainUI
@onready var SpecialFightButton: Control = %SpecialFightButton

func setInfo(_map_node: MapNodeGD) -> void:
	super(_map_node)

	var base_sprite: Texture2D = map_node.getEncounterDatastore().getBaseSprite()
	var frames: Array[Texture2D] = map_node.getEncounterDatastore().getFrames()
	EncounterMainUI.setInfo(base_sprite, frames)
	SpecialFightButton.text = map_node.getSpecialFightType()
	
func getMinimapFadeNodes() -> Array: return [EncounterMainUI]
func getStashFadeNodes() -> Array: return [EncounterMainUI]

func onRegularFightPressed() -> void:
	map_node.onCreateRegularFight()

func onSpecialFightPressed() -> void:
	map_node.onCreateSpecialFight()
	
