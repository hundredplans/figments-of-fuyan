extends TextureRect

signal pressed

@export var global_mouse_filter: Control.MouseFilter

var is_mouse_in_ui: bool
var is_extra_frame: bool
var frames: Array[Texture2D]
var bitmap_frames: Array[BitMap]
var disable_update_modulate: bool

@onready var BitmapButton: TextureButton = %BitmapButton
@onready var FrameSprite: TextureRect = %FrameSprite
const SWAP_FRAME_TIME: float = 1.0

func setInfo(base: Texture2D, _frames: Array[Texture2D], _bitmap_frames: Array[BitMap] = []) -> void:
	texture = base
	frames = _frames
	bitmap_frames = _bitmap_frames
	FrameSprite.expand_mode = expand_mode
	FrameSprite.stretch_mode = stretch_mode
	
	onUpdateGlobalMouseFilter()
	onUpdateFrames()
	
func onUpdateFrames(extra_tx: Texture2D = null) -> void:
	var tx: Texture2D = extra_tx
	if extra_tx == null:
		var index: int = 0
		if !(FrameSprite.texture == null or frames.find(FrameSprite.texture) == -1):
			index = (frames.find(FrameSprite.texture) + 1) % frames.size()
		tx = frames[index]
		
		if !bitmap_frames.is_empty():
			BitmapButton.texture_click_mask = bitmap_frames[min(index, bitmap_frames.size() - 1)]
	else: is_extra_frame = true
		
	FrameSprite.texture = tx
	
	await get_tree().create_timer(SWAP_FRAME_TIME).timeout
	if is_extra_frame: is_extra_frame = false; return
	onUpdateFrames()
	
func setExtraFrame(extra_tx: Texture2D) -> void:
	onUpdateFrames(extra_tx)
	
func setBaseSprite(base_sprite: Texture2D) -> void:
	texture = base_sprite

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	onUpdateModulate()
	
func setDisableUpdateModulate(_disable_update_modulate: bool) -> void:
	disable_update_modulate = _disable_update_modulate
	onUpdateModulate()

func onUpdateModulate() -> void:
	if disable_update_modulate: return
	modulate = Color(0.5, 0.5, 0.5) if is_mouse_in_ui else Color.WHITE

func onUpdateGlobalMouseFilter() -> void:
	BitmapButton.mouse_filter = global_mouse_filter

func onButtonPressed() -> void:
	pressed.emit()
