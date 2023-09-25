extends Control
@export var options: PackedStringArray
@export var default: int
@export var label_text: String
@export var open_state: bool
signal item_selected
var button_states: Array = []
var is_animating: bool = false

func _enter_tree() -> void:
	$Label.text = label_text
	$Outside.color = Helper.DARK_BROWN
	$Inside.color = Helper.LIGHT_BROWN
	(func():$Outside.size.x += $Label.size.x + 23; $Inside.size.x += $Label.size.x + 23).call_deferred()
	modify_open_state()
	
func modify_open_state() -> void:
	match open_state:
		false: $OpenButton.text = "Open"
		true: $OpenButton.text = "Close"

func _on_open_button_pressed():
	if $Options.get_child_count() < 1:
		open_state = true
		var options_size: int = options.size() - 1
		var total: int = 0
		var ndefault: int = default
		
		for i in options:
			var binary_button: Control = preload("res://scenes/ui_general/binary_button/binary_button.tscn").instantiate()
			binary_button.label_text = i
			$Options.add_child(binary_button)
			total = int(pow(2, options_size))
			if ndefault >= total:
				binary_button.press()
				ndefault -= total
			options_size -= 1
			binary_button.item_selected.connect(on_item_selected.bind(binary_button))
		$OpenOptions.play("open_options")
		modify_open_state()
		position_binary_buttons.call_deferred()
	else:
		Helper.play_method_on_animation_end("open_options", $OpenOptions, close_options, [], true, self)

func position_binary_buttons() -> void:
	var xbp: int = 0
	var ybp: int = 0
	for button in $Options.get_children():
		button.scale = Vector2(0.6, 0.6)
		xbp = button.get_node("Outside").size.x if xbp == 0 else 0
		button.position.x = max(xbp - 80, 0)
		button.position.y += ybp
		if xbp == 0:
			ybp += button.size.y - 15

func close_options() -> void:
	open_state = false
	for child in $Options.get_children(): 
		child.queue_free()
	modify_open_state()

func on_item_selected(state: int, child: Control) -> void:
	var i: int = int(pow(2, abs(child.get_index() - $Options.get_child_count()) - 1))
	match state:
		0: default -= i
		1: default += i
	item_selected.emit(default)
