class_name FancyTextLabel extends RichTextLabel

const FANCY_TEXT_RESOURCE_PATH: String = "res://resources/ui/fancy_text/fancy_text.tres"
const ROBOTO_FONT_PATH: String = "res://assets/fonts/roboto.ttf"
@export var settings: FancyTextLabelSettings
@export var center: bool = true
@export var right: bool = false
@export var hover: bool = false
var infos: Array[InfoWithTier]

signal mouse_in_ui

func setText(_text: String) -> void:
	text = _text
	if text.is_empty(): return
		
	var fancy_text: FancyText = load(FANCY_TEXT_RESOURCE_PATH)
	var regex := RegEx.new()
	
	onFofIconsReplace(regex, fancy_text)
	onFofImagesReplace(regex, fancy_text)
	onColoredTextReplace(regex)
	
	text = text.insert(0, "[outline_size=" + str(settings.outline_size) + "][font=" + \
	ROBOTO_FONT_PATH + "][font_size={" + str(settings.font_size) + "}]")
	text += "[/font_size][/font][/outline_size]"

	if center:
		text = text.insert(0, "[center]")
		text += "[/center]"
		
	elif right:
		text = text.insert(0, "[right]")
		text += "[/right]"

func onColoredTextReplace(regex: RegEx) -> void:
	for rarity in Game.Rarities.values():
		var colored_text: String = Game.getRarityString(rarity)
		regex.compile("\\ba?" + colored_text + "\\b")
		
		var offset: int = 0
		while(true):
			var _result: RegExMatch = regex.search(text, offset)
			if _result == null: break
			var result: String = _result.get_string()
			var new_result: String = onReplaceCBTName(colored_text, rarity)
			var replace_index: int = _result.get_start()
				
			offset = _result.get_end() + (new_result.length() - result.length())
			text = text.left(replace_index) + new_result + text.right(-(replace_index + result.length()))
	
func onReplaceCBTName(colored_text: String, rarity: Game.Rarities) -> String:
	var new_result: String = "[color=" + Game.getRarityColor(rarity).to_html() + "]" + colored_text + "[/color]"
	return new_result

func _ready() -> void:
	setText(text)
	clip_contents = false

func onFofIconsReplace(regex: RegEx, fancy_text: FancyText) -> void:
	infos = []
	for fof_icon_fancy_text: FofIconFancyText in fancy_text.icons:
		regex.compile("(\\[[1-4]?" + str(fof_icon_fancy_text.name) + "=[0-9]+\\])")
		var offset: int = 0
		while(true):
			var _result: RegExMatch = regex.search(text, offset)
			if _result == null: break
			
			var result: String = _result.get_string()
			var id: int = int(result.substr(3, -1))
			var info: FofInfo = Helper.getFofInfoID(fof_icon_fancy_text.fof_type, id)
			
			var icon_path: String = info.getIcon().resource_path
			
			var icon_size: String = str(int(settings.font_size * 1.5))
			
			var new_result: String = "[img=" + icon_size + "x" + icon_size + ",center]" + icon_path + "[/img]"
			
			var tier: int = int(result[1])
			new_result = new_result.insert(0, onReplaceCBTName(info.name, info.rarity) + " ")
			infos.append(InfoWithTier.new(info, tier))
			
			var replace_index: int = _result.get_start()
			offset = _result.get_end() + (new_result.length() - result.length())
			text = text.left(replace_index) + new_result + text.right(-(replace_index + result.length()))
			
func onFofImagesReplace(regex: RegEx, fancy_text: FancyText) -> void:
	for image_fancy_text in fancy_text.images:
		var compile_text: String = "\\b" + image_fancy_text.name + "\\b"
		if image_fancy_text.capture_preceding_number_plus:
			compile_text = compile_text.insert(0, "([0-9]*)?((\\[[0-9]*\\])?\\+?-?([0-9]*)?\\s)?")
		regex.compile(compile_text)
		
		while(true):
			var _result: RegExMatch = regex.search(text)
			if _result == null: break
			
			var result: String = _result.get_string()
			var icon_path: String = image_fancy_text.tx.resource_path
			var first_section: String = result.substr(0, result.find(image_fancy_text.name))
			
			var replacement_string: String =  "[img=" + str(settings.font_size) + "x" + str(settings.font_size) + "]" + icon_path + "[/img]"
			if !image_fancy_text.color.is_empty():
				replacement_string = replacement_string.insert(0, "[color=" + image_fancy_text.color + "]" + first_section + "[/color]")
			else: replacement_string = replacement_string.insert(0, first_section)
			var replace_index: int = _result.get_start()
			text = text.left(replace_index) + replacement_string + text.right(-(replace_index + result.length()))

func _on_child_entered_tree(node: Control) -> void:
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE

#region Hover
func setHover(state: bool) -> void:
	hover = state
	
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(is_mouse_in_ui)
	if hover:
		Game.onMouseInUITooltip(is_mouse_in_ui, infos, self)
#endregion

#region Tooltip Infos
func getInfos() -> Array[InfoWithTier]:
	return infos
#endregion
