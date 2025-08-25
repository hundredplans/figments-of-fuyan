class_name EncounterDatastore extends Resource

@export var id: int
@export var background_icon: Texture2D
@export var background_main_color: Color

@export var base_sprite: Texture2D
@export var frames: Array[Texture2D]
@export var hands: Array[Texture2D]

@export_group("Encounter")
@export var bitmap_frames: Array[BitMap]
@export var drag_zone_material: ShaderMaterial
@export var drag_zone_name: String
@export var drag_zone_label_color: Color
@export_group("")

func getBackgroundMainColor() -> Color:
	return background_main_color
	
func getBackgroundIcon() -> Texture2D:
	return background_icon

func getBaseSprite() -> Texture2D:
	return base_sprite
	
func getFrames() -> Array[Texture2D]:
	return frames

func getDragZoneName() -> String:
	return drag_zone_name

func getHands() -> Array[Texture2D]:
	return hands

func getDragZoneMaterial() -> ShaderMaterial:
	return drag_zone_material

func getDragZoneLabelColor() -> Color:
	return drag_zone_label_color

func getBitmapFrames() -> Array[BitMap]:
	return bitmap_frames
