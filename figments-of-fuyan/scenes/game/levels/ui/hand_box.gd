extends HBoxContainer

const EXIT_DELAY: float = 0.2
var selectable_cards: bool = false
var pinned: bool = false
var is_up: bool = false
var parent: Control

func setInfo(_parent: Control) -> void:
	parent = _parent

func onPin() -> void:
	pinned = true
	if !is_up:
		onUp()
	
func onUnpin() -> void:
	pinned = false
	if !mouse_in_ui:
		onDown()

func onSelectableCards(_selectable_cards: bool) -> void:
	selectable_cards = _selectable_cards
	for Card in get_children():
		Card.setDisabled(!selectable_cards)

var mouse_in_ui: bool = false
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	if !pinned:
		if state: onUp()
		else: onDown()
		
func _on_child_entered_tree(node: Node) -> void:
	pass
	#node.mouse_entered.connect(onMouseInUI.bind(true))
	#node.mouse_exited.connect(onMouseInUI.bind(false))

const MOVE_TIME: float = 1
var moving: bool = false
func onUp() -> void:
	onTweenPosition(1)
	
func onDown() -> void:
	onTweenPosition(-1)

func onTweenPosition(direction: int) -> void:
	if !moving:
		pass
		#moving = true
		#var tween := get_tree().create_tween()
		#tween.tween_property(self, "position:y", size.y * direction, MOVE_TIME)
		#await tween.finished
		#moving = false
