extends Control
signal queued
signal remove_favorite
@onready var Outside: ColorRect = $Background/ACOutside
@onready var Items: Node3D = $Items/SubViewportContainer/SubViewport/Items
var favorite_items: Array = []
var label_texts: Array = []
var variations: Array = []

func _ready() -> void:
	for i in range(favorite_items.size()):
		var item: Node3D = load(favorite_items[i]).instantiate()
		Items.add_child(item)
		var kid: Control = $Items/ItemBoxes.get_child(i)
		kid.get_node("Label").text = label_texts[i]
		kid.get_node("Button").pressed.connect(on_button_pressed.bind(i))
		on_position_item(item, kid.position.y + 45, Vector2(float(-103 * 0.2), float(-181 * 0.2)))
#	load_sliders()

var oo: Array = [0.0, 0.0]
func load_sliders():
	for i in range(2):
		var slider = preload("res://scenes/ui_general/scale_button/scale_button.tscn").instantiate()
		slider.position.x += i * 500
		slider.min_max = Vector2(-300, 300)
		slider.steps = Vector2(1, 2)
		slider.item_selected.connect(on_slider_item_selected.bind(i))
		get_parent().get_parent().add_child(slider)
func on_slider_item_selected(i: int, j: int) -> void:
	print(oo)
	oo[j] = float(i * 0.2)
	for n in range(Items.get_children().size()):
		on_position_item(Items.get_child(n), $Items/ItemBoxes.get_child(n).position.y + 45, Vector2(oo[0], oo[1]))
		
func on_position_item(item: Node3D, y: float, xy: Vector2) -> void:
	item.position = Vector3(0, _remap(y, -xy.x, xy.y), 0)

func _remap(pos: float, n: float, m: float) -> float:
	return remap(pos, 0, 990, n, m)

func on_button_pressed(i: int) -> void:
	print(i)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Favorite") \
	or (Input.is_action_just_pressed("LeftClick") or Input.is_action_just_pressed(Helper.interact_button())) and !(Rect2(Outside.global_position, Outside.size).has_point(get_viewport().get_mouse_position())):
		_queue_free()

	if Input.is_action_just_pressed("RightClick"): 
		var items: Array = $Items/ItemBoxes.get_children().filter(func(x: Control): return Rect2(x.global_position, x.size).has_point(get_viewport().get_mouse_position()))
#		if items.size() == 1:
#			remove_favorite.emit(items.name - 1)

func _queue_free() -> void:
	queued.emit()
	queue_free()
