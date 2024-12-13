class_name FancyTextLabel extends RichTextLabel

const FANCY_TEXT_RESOURCE_PATH: String = "res://resources/ui/fancy_text/fancy_text.tres"
const ROBOTO_FONT_PATH: String = "res://assets/fonts/roboto.ttf"
@export var settings: FancyTextLabelSettings
@export var center: bool = true

func setText(_text: String) -> void:
	if !_text.is_empty():
		text = _text
		var fancy_text: FancyText = load(FANCY_TEXT_RESOURCE_PATH)
		var regex := RegEx.new()
		
		onCardNamesReplace(regex)
		onFofIconsReplace(regex, fancy_text)
		onFofImagesReplace(regex, fancy_text)
		onColoredTextReplace(regex, fancy_text)
		text = text.insert(0, "[outline_size=" + str(settings.outline_size) + "][font=" + \
		ROBOTO_FONT_PATH + "][font_size={" + str(settings.font_size) + "}]")
		text += "[/font_size][/font][/outline_size]"
		
		if center:
			text = text.insert(0, "[center]")
			text += "[/center]"

func onColoredTextReplace(regex: RegEx, fancy_text: FancyText) -> void:
	for colored_text in Game.Rarities:
		pass

func _ready() -> void:
	setText(text)
	clip_contents = false

func onCardNamesReplace(regex: RegEx) -> void:
	regex.compile("{id=\\d+,a=[ft],[a-zA-Z]+}")
	while(true):
		var _result: RegExMatch = regex.search(text)
		if _result == null: break
		
		var result: String = _result.get_string()
		text = text.replace(result, "[color=light_slate_gray]Palmy[/color]")

func onFofIconsReplace(regex: RegEx, fancy_text: FancyText) -> void:
	for fof_icon_fancy_text in fancy_text.icons:
		regex.compile("(\\[" + str(fof_icon_fancy_text.name) + "=[0-9]+\\])")
		while(true):
			var _result: RegExMatch = regex.search(text)
			if _result == null: break
			
			var result: String = _result.get_string()
			var icon_path: String = Helper.getFofInfoID(fof_icon_fancy_text.fof_type, int(result)).getTextIcon().resource_path
			
			var icon_size: String = str(int(settings.font_size * 1.5))
			var new_result: String = "[img=" + icon_size + "x" + icon_size + ",center]" + icon_path + "[/img]"
			var replace_index: int = _result.get_start()
			text = text.left(replace_index) + new_result + text.right(-(replace_index + result.length()))
			
func onFofImagesReplace(regex: RegEx, fancy_text: FancyText) -> void:
	for image_fancy_text in fancy_text.images:
		var compile_text: String = image_fancy_text.name
		if image_fancy_text.capture_preceding_number_plus:
			compile_text = compile_text.insert(0, "((\\+?[0-9]+|\\[[0-9]+\\])\\s)?\\b")
		
		compile_text = compile_text.insert(0, "\\b")
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
