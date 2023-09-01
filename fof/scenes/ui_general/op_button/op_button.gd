extends Control
@export var options: PackedStringArray
@export var default: int
@export var label_text: String
signal item_selected

func _ready() -> void:
	$OptionButton.item_selected.connect(func(i: int): item_selected.emit(i))
	for i in options:
		$OptionButton.add_item(i)
		
	if default < $OptionButton.item_count:
		$OptionButton.select(default)
		
	$Label.text = label_text
	$Outside.color = Helper.DARK_BROWN
	$Inside.color = Helper.LIGHT_BROWN
	
	(func(): $Label.position.x = $OptionButton.get_minimum_size().x + 15;\
	$Outside.size.x += $Label.get_minimum_size().x + $OptionButton.get_minimum_size().x + 5;\
	$Inside.size.x += $Label.get_minimum_size().x + $OptionButton.get_minimum_size().x + 5).call_deferred()
