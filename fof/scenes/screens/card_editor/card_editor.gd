extends Control
signal fileloader_state
var ID: int = 0
var rarity: int = 2
var stats: Array = [1,1,1,1]
var personality_sliders: Array = [4,4,4,4,4]
var height: Dictionary

const TID: int = 2
const FILE_LOADER_NAME: String = "Card"

@onready var ModelWorld: Node3D = $ModelArea/ModelViewer/SubViewport/ModelWorld
@onready var Internal: LineEdit = $CardCreator/EditFileName/Internal
@export var CardText: TextEdit
@export var FlavorText: TextEdit

var old_stat_texts: Array = ["", "", "", ""]

@export var Y_GHOST_OFFSET: int = -260

func _process(_delta: float) -> void:
	if is_mouse_in_model_viewer and Input.is_action_just_pressed("RightClick"): 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().update_mouse_cursor_state()
		
	if Input.is_action_just_released("RightClick"): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_mouse_in_model_viewer and Input.is_action_pressed("RightClick"):
			ModelWorld.get_node("Model").rotation_degrees.y += event.relative.x
		elif !ActiveHeightControl.is_empty(): 
			on_align_height_control(ActiveHeightControl[0], ActiveHeightControl[1], event.relative.y)

func on_align_height_control(HeightControl: Control, Arrow: Node3D, y_offset: float) -> void:
	HeightControl.position.y += y_offset
	Arrow.position.y = Camera.project_position(HeightControl.global_position + Vector2(0, -260), 3).y
	HeightControl.HeightLabel.text = str(snapped(Arrow.position.y, 0.01))

func _ready():
	if get_parent() == get_tree().get_root(): $MoveScreen.play_backwards("move_screen")
	for child in $CardCreator/Stats.get_children():
		child.text_submitted.connect(on_stat_text_submitted.bind(child.get_index()))
		child.text_changed.connect(on_stat_text_changed.bind(child))

	for child in $AISettings.get_children():
		child.item_selected.connect(on_ai_settings_item_selected.bind(child.get_index()))
		
	height_arrows = [EyeArrow, TopArrow, WeaponArrow]
	height_controls = [EyeControl, TopControl, WeaponControl]
	on_set_inital_height_controls()
	for i in range(height_controls.size()):
		height_controls[i].GrabButton.button_down.connect(on_move_height_control.bind(height_controls[i], height_arrows[i]))
		height_controls[i].GrabButton.button_up.connect(on_height_control_inactive)

func on_ai_settings_item_selected(item: int, i: int) -> void:
	personality_sliders[i] = item

func on_stat_text_submitted(__: String, i: int) -> void:
	i = i + 1
	match i:
		3: $CardCreator/CardText.grab_focus()
		4: $CardCreator/Stats/Attack.grab_focus()
		_: 
			var ledit: LineEdit = $CardCreator/Stats.get_child(i)
			ledit.grab_focus()
			ledit.caret_column = ledit.text.length()

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
	$CardCreator/RarityColor.color = Helper.rarity_colors[i]
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
	$CardCreator/Stats/Energy.grab_focus()

var height_arrows: Array = []
var height_controls: Array = []
func _on_save_card_pressed():
	var card_text: String = CardText.text.replace("\n", " ")
	var text: Dictionary = {
		"raw": card_text,
		"compiled": $TextProcessing.on_apply_text_processing(card_text)
	}
	height = {"eye": float(EyeControl.HeightLabel.text), "top": float(TopControl.HeightLabel.text), "weapon": float(WeaponControl.HeightLabel.text)}
	
	var contents: String = "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s"\
	% [stats[0], stats[1], stats[2], stats[3], rarity, text, FlavorText.text.replace("\n", " "),
	personality_sliders[0], personality_sliders[1], personality_sliders[2], personality_sliders[3], personality_sliders[4], height]
	var item_dict: Dictionary = Helper.write_to_base_game_file(FILE_LOADER_NAME, $CardCreator/EditFileName, contents, TID)
	
	if item_dict:
		Helper.create_base_game_id_dir(item_dict, FILE_LOADER_NAME)
		ID = item_dict.id
		
		var dir_path: String = "res://assets/base_game/cards/" + item_dict.bgfn 
		if DirAccess.dir_exists_absolute(dir_path):
			var audio_dict := AudioDictGD.new()
			ResourceSaver.save(audio_dict, dir_path + "/audio.tres")

var FileLoader: Control
func _on_load_card_pressed():
	$Buttons/LoadCard.disabled = true
	FileLoader = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	
	FileLoader.get_node("Search/SearchEdit").text = search_item_text
	FileLoader.page = fileloader_page
	
	FileLoader.on_ready(FILE_LOADER_NAME)
	if search_item_selected > 0 or search_item_text.length() > 0:
		FileLoader._on_search_item_selected(search_item_selected)
	
	FileLoader.item_selected.connect(on_item_selected)
	FileLoader.queued.connect(on_fileloader_queued)
	add_child(FileLoader)
	FileLoader.get_node("Search/SearchOptions").select_item(search_item_selected)
	
var fileloader_page: int = 0
var search_item_selected: int = 0
var search_item_text: String = ""

func on_fileloader_queued() -> void:
	$Buttons/LoadCard.disabled = false
	fileloader_page = FileLoader.page
	search_item_selected = FileLoader.search_item_selected
	search_item_text = FileLoader.get_node("Search/SearchEdit").text
	
func on_item_selected(item_info: Dictionary, change_rarity: bool = true) -> void:
	$CardCreator/EditFileName.set_text(item_info.iname, item_info.sname)
	for stat in ["a", "h", "s", "e"]:
		var stat_edit: LineEdit = $CardCreator/Stats.get_node(Helper.stat_ai_dict[stat])
		if item_info[stat] >= 0:
			stat_edit.text = str(item_info[stat])
			on_stat_text_changed(stat_edit.text, stat_edit)
		else: stat_edit.text = ""
	
	for ai_stat in ["aii", "aia", "aiw", "ait", "aic"]:
		var btn: Control = get_node("AISettings/" + Helper.stat_ai_dict[ai_stat] + "Button")
		btn.default = item_info[ai_stat]
		btn.set_grabber_position()
		
	$CardCreator/FlavorText.text = item_info.flavor
	$CardCreator/CardText.text = item_info.text.raw
	
	ID = item_info.id
	var texture_path: String = "res://assets/base_game/cards/card_ui/default_art_max.png"
	var hero_bgfn: String = item_info.bgfn if item_info.r != 7 else Helper.id_to_dict($Heroes.id_to_base(item_info.id), "Card").bgfn
	var card_texture_path: String = "res://assets/base_game/cards/" + hero_bgfn + "/art_max.png"
	if FileAccess.file_exists(card_texture_path):
		texture_path = card_texture_path
	$CardCreator/Art.texture = load(texture_path)
	
	on_load_model(hero_bgfn)
	
	if change_rarity:
		_on_choose_rarity_item_selected(item_info.r)
		$CardCreator/ChooseRarity.select_item(item_info.r)
	
	if typeof(item_info.height) == TYPE_DICTIONARY:
		if !item_info.height.has("weapon"): item_info.height.weapon = 1.0
		height = item_info.height
		EyeArrow.position.y = height.eye
		TopArrow.position.y = height.top
		WeaponArrow.position.y = height.weapon
		
		on_set_inital_height_controls()

func _on_delete_card_pressed():
	Helper.on_delete_item(FILE_LOADER_NAME, str(ID), Internal, self, Settings.cards_can_delete_directory)

var _Roboto20: Theme = preload("res://assets/UI/roboto/roboto20.tres")
func on_load_model(bgfn: String) -> void:
	for child in ModelWorld.get_node("Model").get_children():
		child.queue_free()
		
	var model_path: String = "res://assets/base_game/cards/card_ui/default_model.glb"
	var card_model_path: String = "res://assets/base_game/cards/" + bgfn + "/model.glb"
	if FileAccess.file_exists(card_model_path):
		model_path = card_model_path
		
	var model: Node3D = load(model_path).instantiate()
	ModelWorld.get_node("Model").add_child(model)
	
	for button in $ModelArea/ModelControls.get_children(): button.queue_free()
	if model.has_node("AnimationPlayer"):
		var ani_player: AnimationPlayer = model.get_node("AnimationPlayer")
		for ani in ani_player.get_animation_library("").get_animation_list():
			var btn := Button.new()
			btn.text = ani
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.theme = _Roboto20
			btn.pressed.connect(on_play_model_animation.bind(ani_player, ani))
			$ModelArea/ModelControls.add_child(btn)

func on_play_model_animation(ani_player: AnimationPlayer, ani: String) -> void:
	ani_player.play(ani)

func _on_model_viewer_button_button_down():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_model_viewer_button_button_up():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

const EMPTY_INFO: Dictionary = {
	"id": 0,
	"tid": 2,
	"iname": "",
	"sname": "",
	"a": -1,
	"h": -1,
	"s": -1,
	"e": -1,
	"r": 2,
	"text": "",
	"flavor": "",
	"aii": 4,
	"aiw": 4,
	"aic": 4,
	"ait": 4,
	"aia": 4,
	"height": {"eye": 1.6, "top": 1.8},
	"bgfn": "",
}
func _on_empty_card_pressed(): on_item_selected(EMPTY_INFO, false)

@onready var WeaponControl: Control = %WeaponControl
@onready var EyeControl: Control = %EyeControl
@onready var TopControl: Control = %TopControl

@onready var WeaponArrow: Node3D = %WeaponArrow
@onready var EyeArrow: Node3D = %EyeArrow
@onready var TopArrow: Node3D = %TopArrow
@onready var Camera: Camera3D = $ModelArea/ModelViewer/SubViewport/Camera3D

var DEFAULT_HEIGHT_CONTROL_OFFSET: Vector2 = Vector2(20, -20)
func on_set_inital_height_controls() -> void:
	for i in range(height_controls.size()):
		height_controls[i].global_position = Camera.unproject_position(height_arrows[i].global_position)
		height_controls[i].global_position += DEFAULT_HEIGHT_CONTROL_OFFSET
		height_controls[i].HeightLabel.text = str(snapped(height_arrows[i].position.y, 0.01))
	
func on_height_control_inactive() -> void: ActiveHeightControl = []
	
var ActiveHeightControl: Array = []
func on_move_height_control(HeightControl: Control, Arrow: Node3D) -> void:
	ActiveHeightControl = [HeightControl, Arrow]


var is_mouse_in_model_viewer: bool = false
func _on_model_viewer_control_mouse_entered(): is_mouse_in_model_viewer = true
func _on_model_viewer_control_mouse_exited(): is_mouse_in_model_viewer = false
