class_name FancyTextLabel extends RichTextLabel

const FANCY_TEXT_RESOURCE_PATH: String = "res://resources/ui/fancy_text/fancy_text.tres"
const ROBOTO_FONT_PATH: String = "res://assets/fonts/roboto.ttf"
@export var settings: FancyTextLabelSettings

func setText(_text: String) -> void:
	if !_text.is_empty():
		text = _text
		var fancy_text: FancyText = load(FANCY_TEXT_RESOURCE_PATH)
		var regex := RegEx.new()
		
		onFofIconsReplace(regex, fancy_text)
		onFofImagesReplace(regex, fancy_text)
		text = text.insert(0, "[outline_size=" + str(settings.outline_size) + "][center][font=" + \
		ROBOTO_FONT_PATH + "][font_size={" + str(settings.font_size) + "}]")
		text += "[/font_size][/font][/center][/outline_size]"

func _ready() -> void:
	setText(text)

func onFofIconsReplace(regex: RegEx, fancy_text: FancyText) -> void:
	for fof_icon_fancy_text in fancy_text.icons:
		regex.compile("(\\[" + str(fof_icon_fancy_text.name) + "=[0-9]+\\])")
		for _result in regex.search_all(text):
			var result: String = _result.get_string()
			var icon_path: String = Helper.getFofInfoID(fof_icon_fancy_text.fof_type, int(result)).getIcon().resource_path
			text = text.replace(result, \
			"[img=" + str(settings.font_size) + "x" + str(settings.font_size) + "]" + icon_path + "[/img]")
			
func onFofImagesReplace(regex: RegEx, fancy_text: FancyText) -> void:
	for image_fancy_text in fancy_text.images:
		var compile_text: String = image_fancy_text.name
		if image_fancy_text.capture_preceding_number_plus:
			compile_text = compile_text.insert(0, "((\\+?[0-9]+|\\[[0-9]+\\])\\s)?")
			
		regex.compile(compile_text)
		for _result in regex.search_all(text):
			var result: String = _result.get_string()
			var icon_path: String = image_fancy_text.tx.resource_path
			var first_section: String = result.substr(0, result.find(image_fancy_text.name))
			
			var replacement_string: String =  "[img=" + str(settings.font_size) + "x" + str(settings.font_size) + "]" + icon_path + "[/img]"
			if !image_fancy_text.color.is_empty():
				replacement_string = replacement_string.insert(0, "[color=" + image_fancy_text.color + "]" + first_section + "[/color]")
			else: replacement_string = replacement_string.insert(0, first_section)
				
			text = text.replacen(result, replacement_string)
