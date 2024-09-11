@tool
extends Node

#region Exports
@export var card_info: CardInfo:
	set(_card_info):
		onUnitChanged(_card_info)
		card_info = _card_info
#endregion

#region Globals
@onready var World: Node3D = $World
@onready var ColShapeHolder: Node3D = $PlaceCollisionShapeHere
@onready var Heights: Node3D = %Heights
@onready var Camera: Camera3D = %ChampionCamera
#endregion

func _ready() -> void:
	if !Engine.is_editor_hint() and card_info != null:
		for child in World.get_children() + ColShapeHolder.get_children(): child.free()
		var card: CardGD = SavedData.onLoadModel(SavedDataCard.new(card_info.id), World)
		card.onCreateModel()
		card.setOwner(self)
		card.position = Vector3.ZERO
		
		if card.info.collision_shape != null:
			var col_shape: CollisionShape3D = card.info.collision_shape.instantiate()
			ColShapeHolder.add_child(col_shape)
			col_shape.owner = self
		
		for box in Heights.get_children():
			box.position.y = card.info[box.stat]
			box.position.x = box.default_x
		
		if card.info is ChampionCardInfo:
			if card.info.champion_select_posrot == null: card.info.champion_select_posrot = PosRot.new()
			Camera.position = card.info.champion_select_posrot.pos
			Camera.rotation_degrees = card.info.champion_select_posrot.rot
		
		var packed_scene := PackedScene.new()
		packed_scene.pack(self)
		ResourceSaver.save(packed_scene, scene_file_path)

func onUnitChanged(_card_info: CardInfo) -> void:
	if _card_info == null and card_info != null and ColShapeHolder.get_child_count() > 0:
		var col_shape: CollisionShape3D = ColShapeHolder.get_child(0)
		var packed_scene := PackedScene.new()
		packed_scene.pack(col_shape)
		card_info.collision_shape = packed_scene
	
		if card_info is ChampionCardInfo and Camera.position != Vector3.ZERO:
			card_info.champion_select_posrot = PosRot.new(Camera.position, Camera.rotation_degrees)
			
		Camera.position = Vector3.ZERO
		Camera.rotation_degrees = Vector3.ZERO
		for box in Heights.get_children():
			if box.position.y > 0: card_info[box.stat] = box.position.y
			box.position.y = 0
			box.position.x = box.default_x
		
		var image := Image.new()
		image = Image.create_empty(80, 80, false, Image.FORMAT_RGBA8)
		
		for x in range(80):
			for y in range(80):
				image.set_pixel(x, y, card_info.art_pop.get_pixel(\
				x + card_info.art_mini_coordinate.x, y + card_info.art_mini_coordinate.y))
			
		image.save_png(card_info.art_pop.resource_path.replace("art_pop", "art_mini"))
		
		ResourceSaver.save(card_info)
		for child in World.get_children() + ColShapeHolder.get_children(): child.free()
			
