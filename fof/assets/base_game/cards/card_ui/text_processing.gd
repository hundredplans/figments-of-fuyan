extends Node

@export var CardUI: Control

func on_apply_text_processing(text: String, TextLabel: RichTextLabel) -> void:
	text = text.insert(0, "[center]")
	text += "[/center]"
	
	
	for type in DirAccess.get_files_at("res://assets/base_game/cards/card_ui/bbcode/"):
		on_add_bbcode_image(TextLabel, type.left(-4))

	TextLabel.text = text

func on_add_bbcode_image(TextLabel: RichTextLabel, type: String) ->  void:
	TextLabel.text = TextLabel.text.replace(type, "[img=15x15]res://assets/base_game/cards/card_ui/bbcode/" + type + ".png[/img]")
