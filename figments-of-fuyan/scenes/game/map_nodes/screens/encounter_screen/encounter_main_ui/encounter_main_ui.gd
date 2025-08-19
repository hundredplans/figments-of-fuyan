extends TextureRect

signal pressed

@export var global_mouse_filter: Control.MouseFilter

var is_mouse_in_ui: bool
var is_extra_frame: bool
var frames: Array[Texture2D]

@onready var FrameSprite: TextureRect = %FrameSprite
const SWAP_FRAME_TIME: float = 1.0

func setInfo(base: Texture2D, _frames: Array[Texture2D]) -> void:
	texture = base
	frames = _frames
	
	onUpdateGlobalMouseFilter()
	onUpdateFrames()
	
func onUpdateFrames(extra_tx: Texture2D = null) -> void:
	var tx: Texture2D = extra_tx
	if extra_tx == null:
		if FrameSprite.texture == null or frames.find(FrameSprite.texture) == -1:
			tx = frames[0]
		else: tx = frames[(frames.find(FrameSprite.texture) + 1) % frames.size()]
	else: is_extra_frame = true
		
	FrameSprite.texture = tx
	
	await get_tree().create_timer(SWAP_FRAME_TIME).timeout
	if is_extra_frame: is_extra_frame = false; return
	onUpdateFrames()
	
func setExtraFrame(extra_tx: Texture2D) -> void:
	onUpdateFrames(extra_tx)
	
func setBaseSprite(base_sprite: Texture2D) -> void:
	texture = base_sprite

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui:
		pressed.emit()

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	modulate = Color(0.5, 0.5, 0.5) if state else Color.WHITE

func onUpdateGlobalMouseFilter() -> void:
	mouse_filter = global_mouse_filter
