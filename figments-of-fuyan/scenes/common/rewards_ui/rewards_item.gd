extends Control

@export var card_icon: Texture2D
@export var shilling_icon: Texture2D
@onready var IconRect: TextureRect = %IconRect
@onready var ItemLabel: Label = %ItemLabel
@onready var MainContainer: PanelContainer = %MainContainer

signal mouse_signal
signal pressed

@export var TooltipPacked: PackedScene
const TOOLTIP_DELAY: float = 0.3
const OFFSET := Vector2(10, -40)
const TAKEN_COLOR := Color(0.2, 0.2, 0.2)

var taken: bool
var item: Variant
func setInfo(_item: Variant, is_taken: bool = false) -> void:
	item = _item
	if item is MapEffectGD and item.info.id == 2:
		MainContainer.theme_type_variation = "WhitePanelContainer"
		IconRect.texture = shilling_icon
		ItemLabel.text = "Shillings"
		
	elif item is BoonGD or item is ToolGD:
		match item.info.rarity:
			Game.Rarities.COMMON: MainContainer.theme_type_variation = "BeigePanelContainer"
			Game.Rarities.RARE: MainContainer.theme_type_variation = "TealPanelContainer"
			Game.Rarities.EXALT: MainContainer.theme_type_variation = "YellowPanelContainer"
		
		ItemLabel.text = item.info.getFofName()
		IconRect.texture = item.getIcon()
		
	elif item is Array:
		MainContainer.theme_type_variation = "WhitePanelContainer"
		IconRect.texture = card_icon
		ItemLabel.text = "Cards"
		
	setTaken(is_taken)

var Tooltip: Control
var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	modulate = (Color(0.5, 0.5, 0.5) if (state) else Color(1, 1, 1)) if !taken else TAKEN_COLOR
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	
	if !taken and item is FofGD:
		if state and Tooltip == null:
			await get_tree().create_timer(TOOLTIP_DELAY).timeout
			if mouse_in_ui and !taken:
				Tooltip = TooltipPacked.instantiate()
				add_child(Tooltip)
				Tooltip.setInfo(item)
				Tooltip.global_position = get_viewport().get_mouse_position() + OFFSET
			
	if !mouse_in_ui and Tooltip != null:
		Tooltip.queue_free()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and mouse_in_ui and !taken:
		pressed.emit(item)
		
func setTaken(state: bool) -> void:
	taken = state
	if taken:
		IconRect.texture = null
		modulate = Color(TAKEN_COLOR)
		if Tooltip != null: Tooltip.queue_free()
	
