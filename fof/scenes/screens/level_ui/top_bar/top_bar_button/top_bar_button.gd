@tool
extends TextureButton
signal mouse_in_ui
@export var texture: Texture2D
@export var image: Image

const DISABLED_COLOR := Color(0.6, 0.6, 0.6)

func _ready() -> void:
	setTexture(texture)

func _on_mouse_entered():
	mouse_in_ui.emit(true)
	if !disabled:
		material = preload("res://assets/base_game/cards/game_card/materials/card_selected_material.tres")

func _on_mouse_exited():
	mouse_in_ui.emit(false)
	material = null

func setDisabled(state: bool) -> void:
	disabled = state
	if state: modulate = DISABLED_COLOR
	else: modulate = Color(1, 1, 1)

func setTexture(tx: Texture) -> void:
	texture_normal = tx
	if tx != null and owner != get_tree().edited_scene_root:
		if image == null: Helper.create_button_clickmask(self)
		else: texture_click_mask = Helper.onCreateClickmask(image)
		
