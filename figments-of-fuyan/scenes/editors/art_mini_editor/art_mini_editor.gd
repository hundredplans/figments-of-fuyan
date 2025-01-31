extends Node

@onready var MainContainer: Container = %MainContainer
@export var ArtMiniNodePacked: PackedScene


func _ready() -> void:
	for info in Helper.getFofInfoArray(CardInfo):
		var ArtMiniNode: Control = ArtMiniNodePacked.instantiate()
		MainContainer.add_child(ArtMiniNode)
		ArtMiniNode.setInfo(info)
	
func onCreateArtMiniImage(info: CardInfo) -> Image:
	var image := Image.new()
	image = Image.create_empty(80, 80, false, Image.FORMAT_RGBA8)
		
	for x in range(80):
		for y in range(80):
			image.set_pixel(x, y, info.art_pop.get_pixel(\
			x + info.art_mini_coordinate.x, y + info.art_mini_coordinate.y))
	return image
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		onSave()
		
func onSave() -> void:
	for ArtMiniNode in MainContainer.get_children():
		var info: CardInfo = ArtMiniNode.card_info
		
		var coords: Vector2i = ArtMiniNode.getCoordinates()
		var mini_path: String = info.art_pop.resource_path.replace("art_pop", "art_mini") 
		
		if info.art_mini == null:
			var tx: Texture = load(mini_path)
			if tx != null:
				info.art_mini = tx
		
		if coords != info.art_mini_coordinate:
			info.art_mini_coordinate = coords
			
			var image: Image = onCreateArtMiniImage(info)
			image.save_png(mini_path)
			
			var tx: Texture = load(mini_path)
			if tx != null: info.art_mini = tx
		
		ResourceSaver.save(info)
		
