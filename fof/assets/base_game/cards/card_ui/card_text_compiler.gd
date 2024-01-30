extends Node
const TID: int = 2
const FILE_LOADER_NAME: String = "Card"

func _ready():
	for card in Helper.on_item_dicts("Card"):
		var text: Dictionary = {
			"raw": card.text.raw,
			"compiled": $TextProcessing.on_apply_text_processing(card.text.raw)
		}
		
		$EditFileName/Internal.text = card.iname
		$EditFileName/Showcase.text = card.sname
		
		var contents: String = "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s"\
		% [card.a, card.h, card.s, card.e, card.r, text, card.flavor, card.aic, card.aii, card.aiw, card.ait, card.aia, card.height]
		var item_dict: Dictionary = Helper.write_to_base_game_file(FILE_LOADER_NAME, $EditFileName, contents, TID)
	
		if item_dict:
			Helper.create_base_game_id_dir(item_dict, FILE_LOADER_NAME)
