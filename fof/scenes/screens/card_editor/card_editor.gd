extends Control
signal change_fileloader_state

var ID: int = 0
var rarity: int = 1
var stats: Array = [1,1,1,1]
var personality_sliders: Array = [1,1,1,1,1]

const TID: int = 2
const FILE_LOADER_NAME: String = "Card"

@onready var ModelWorld: Node3D = $ModelViewer/SubViewport/ModelWorld
@onready var Internal: LineEdit = $CardCreator/EditFileName/Internal
@export var CardText: TextEdit
@export var FlavorText: TextEdit

var old_stat_texts: Array = ["", "", "", ""]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and $ModelViewerButton.button_pressed:
		ModelWorld.get_node("Model").rotation_degrees.y += event.relative.x

func _ready():
	if get_parent() == get_tree().get_root(): $MoveScreen.play_backwards("move_screen")
	for child in $CardCreator/Stats.get_children():
		child.text_submitted.connect(on_stat_text_submitted.bind(child.get_index()))
		child.text_changed.connect(on_stat_text_changed.bind(child))

	for child in $AISettings.get_children():
		child.item_selected.connect(on_ai_settings_item_selected.bind(child.get_index()))

func on_ai_settings_item_selected(item: int, i: int) -> void:
	personality_sliders[i] = item

func on_stat_text_submitted(__: String, i: int) -> void:
	i = i + 1
	if i < 4:
		$CardCreator/Stats.get_child(i).grab_focus()
	else:
		Internal.grab_focus()

func on_stat_text_changed(text: String, node: LineEdit) -> void:
	if text.is_valid_int():
		old_stat_texts[node.get_index()] = text
		stats[node.get_index()] = int(node.text)
	elif text != "":
		node.text = old_stat_texts[node.get_index()]
		
func on_stat_submitted(__: String):
	for child in $CardCreator/Stats.get_children():
		child.release_focus()

func _on_choose_rarity_item_selected(i: int):
	var rarity_colors: Dictionary = {
		0: "8e8f88",
		1: "b7a48b",
		2: "5b8500",
		3: "ebdf60",
		4: "a001fb",
		5: "d72500",
		6: "5f91e1",
	}
	$CardCreator/RarityColor.color = rarity_colors[i]
	rarity = i

func _on_card_text_changed():
	if CardText.text.ends_with("\n"):
		CardText.text = CardText.text.left(-1)
		FlavorText.grab_focus()

func _on_flavor_text_changed():
	if FlavorText.text.ends_with("\n"):
		FlavorText.text = FlavorText.text.left(-1)
		FlavorText.release_focus()

func _on_edit_file_name_text_submitted():
	$CardCreator/CardText.grab_focus()

func _on_save_card_pressed():
	var contents: String = "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s"\
	% [stats[0], stats[1], stats[2], stats[3], rarity, CardText.text, FlavorText.text,
	personality_sliders[0], personality_sliders[1], personality_sliders[2], personality_sliders[3], personality_sliders[4]]
	var item_dict: Dictionary = Helper.write_to_base_game_file(FILE_LOADER_NAME, $CardCreator/EditFileName, contents, TID)
	if item_dict and Settings.auto_create_dir == 1:
		var dir_path: String = "res://assets/base_game/cards/"
		if !Array(DirAccess.get_directories_at(dir_path)).any(func(x: String): return x.begins_with(str(item_dict.id))):
			DirAccess.make_dir_absolute(dir_path + item_dict.bgfn)

func _on_load_card_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_item_selected)
	add_child(FileLoader)
	
func on_item_selected(item_info: Dictionary) -> void:
	$CardCreator/EditFileName.set_text(item_info.iname, item_info.sname)
	for stat in ["a", "h", "s", "e"]:
		var stat_edit: LineEdit = $CardCreator/Stats.get_node(Helper.stat_ai_dict[stat])
		stat_edit.text = str(item_info[stat])
		on_stat_text_changed(stat_edit.text, stat_edit)
	
	for ai_stat in ["aii", "aia", "aiw", "ait", "aic"]:
		var btn: Control = get_node("AISettings/" + Helper.stat_ai_dict[ai_stat] + "Button")
		btn.default = item_info[ai_stat]
		btn.set_grabber_position()
		
	$CardCreator/FlavorText.text = item_info.flavor
	$CardCreator/CardText.text = item_info.text
	
	ID = item_info.id
	var texture_path: String = "res://assets/base_game/cards/card/default_art_max.png"
	var card_texture_path: String = "res://assets/base_game/cards/" + item_info.bgfn + "/art_max.png"
	if FileAccess.file_exists(card_texture_path):
		texture_path = card_texture_path
	$CardCreator/Art.texture = load(texture_path)
	
	on_load_model(item_info.bgfn)
	_on_choose_rarity_item_selected(item_info.r)

func _on_delete_card_pressed():
	Helper.on_delete_item(FILE_LOADER_NAME, str(ID), Internal, self, Settings.cards_can_delete_directory)

func on_load_model(bgfn: String) -> void:
	for child in ModelWorld.get_node("Model").get_children():
		child.queue_free()
		
	var model_path: String = "res://assets/base_game/cards/card/default_model.glb"
	var card_model_path: String = "res://assets/base_game/cards/" + bgfn + "/model.glb"
	if FileAccess.file_exists(card_model_path):
		model_path = card_model_path
	ModelWorld.get_node("Model").add_child(load(model_path).instantiate())


func _on_model_viewer_button_button_down():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_model_viewer_button_button_up():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
