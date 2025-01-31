extends ColorRect

@onready var TxRect: TextureRect = %TxRect

var card_info: CardInfo
var started_with_mouse: bool
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("MainInput") and is_mouse_in_ui and event is InputEventMouseMotion and started_with_mouse:
		TxRect.position += event.relative
		TxRect.position.x = clamp(TxRect.position.x, -184, 0)
		TxRect.position.y = clamp(TxRect.position.y, -300, 0)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui: started_with_mouse = true
	elif Input.is_action_just_released("MainInput"): started_with_mouse = false

var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state

func setInfo(_card_info: CardInfo) -> void:
	card_info = _card_info
	TxRect.texture = ImageTexture.create_from_image(card_info.art_pop)
	TxRect.position = card_info.art_mini_coordinate * -1

func getCoordinates() -> Vector2i:
	return Vector2i(round(TxRect.position) * -1)
