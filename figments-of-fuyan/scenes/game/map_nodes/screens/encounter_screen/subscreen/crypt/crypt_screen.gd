extends EncounterSubscreen

@onready var EncounterMainUI: Control = %EncounterMainUI
func setInfo(_map_node: MapNodeGD) -> void:
	super(_map_node)
	
	var base_sprite: Texture2D = map_node.getEncounterDatastore().getBaseSprite()
	var bitmap_frames: Array[BitMap] = map_node.getEncounterDatastore().getBitmapFrames()
	var frames: Array[Texture2D] = map_node.getEncounterDatastore().getFrames()
	EncounterMainUI.setInfo(base_sprite, frames, bitmap_frames)
	
func _on_encounter_main_ui_pressed() -> void:
	EncounterMainUI.setDisableUpdateModulate(true)
	create_stash_screen.emit(null)
	
func onStashScreenExitStart() -> void:
	super()
	EncounterMainUI.setDisableUpdateModulate(false)
	
func getMinimapFadeNodes() -> Array: return [EncounterMainUI]
func getStashFadeNodes() -> Array: return [EncounterMainUI]
