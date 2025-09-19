extends DefaultButton

signal ability_box_pressed

@export var iobject_sprite: Texture2D

@onready var MainContainer: Control = %MainContainer
@onready var BackgroundRect: ColorRect = %BackgroundRect
@onready var TxRect: TextureRect = %TxRect
var item: Variant
var is_action_lock: bool

func _ready() -> void:
	pressed.connect(onAbilityBoxPressed)

func onAbilityBoxPressed() -> void:
	ability_box_pressed.emit(item)

func setItem(_item: Variant) -> void:
	item = _item
	var tx: Texture2D
	if item is CardGD:
		tx = item.getInfo().getArtMini()
		setBorderColor(Game.getTierColor(item.getTier()))
	elif item is ToolGD:
		tx = item.getInfo().getIcon()
		setBorderColor(Game.getTierColor(item.getTier()))
	else:
		tx = iobject_sprite
	
	TxRect.texture = tx
	onUpdateDisabled()
	
func onUpdateDisabled() -> void:
	var disabled: bool = false
	if item is CardGD:
		disabled = item.isEnemy(0)
	elif item is ToolGD:
		disabled = item.getCard().isEnemy(0)
	elif item is ActiveIObjects:
		disabled = item.getCard().isEnemy(0)
	setDisabled(disabled or item == null or item.isActiveEffectDisabled() or is_action_lock)
	
func onMouseInUI(state: bool) -> void:
	super(state)
	
	if item == null or item is ActiveIObjects: return
	Game.onMouseInUITooltip(is_mouse_in_ui, item, self, true, true)

func setBackgroundColor(color: Color) -> void:
	BackgroundRect.color = color
	
func setBorderColor(color: Color) -> void:
	MainContainer.self_modulate = color

func setActionLock(_is_action_lock: bool) -> void:
	is_action_lock = _is_action_lock
	onUpdateDisabled()
