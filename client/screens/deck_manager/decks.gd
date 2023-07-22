extends Control

const max_decks: int = 4
var owned_heroes_path: String = "res://mobile_data/owned_heroes.json"
var deck_button_path: String = "res://screens/deck_manager/deck_button.tscn"
@onready var owned_heroes: Dictionary = Helper.load_json(owned_heroes_path)

func _ready(): 
	create_decks_in_deck_sort()
	
func create_decks_in_deck_sort() -> void:
	for c in $DeckSort.get_children(): c.queue_free()
	if KeepData.current_hero_selected:
		var path: String = "res://mobile_data/decks/%s/" % KeepData.current_hero_selected
		var decks_created: int = 0
		for i in range(max_decks):
			var contents: String = Helper.read_contents(path + str(i) + ".txt")
			if contents:
				create_standard_deck_button(extract_deck_name(contents), i, decks_created)
				decks_created += 1
				
		if decks_created != max_decks:
			create_new_deck_button(decks_created, decks_created)
		
func create_new_deck_button(deck_index: int, decks_created: int):
	var button: Button = load(deck_button_path).instantiate()
	button.get_node("Text").editable = true
	button.position = Vector2(0, 98 * decks_created)
	button.pressed.connect(on_create_new_deck_pressed.bind(deck_index))
	$DeckSort.add_child(button)
		
func create_standard_deck_button(deck_name: String, deck_index: int, decks_created: int):
	var button: Button = load(deck_button_path).instantiate()
	button.position = Vector2(0, 98 * decks_created)
	button.get_node("Text").text = deck_name
	button.pressed.connect(on_deck_pressed.bind(deck_name, deck_index))
	$DeckSort.add_child(button)

func extract_deck_name(contents: String) -> String:
	return contents.substr(0, contents.find("\n"))

func on_deck_pressed(deck_name: String, deck_index: int):
	print(deck_name)
	print(deck_index)

func on_create_new_deck_pressed(deck_index: int) -> void:
	print(deck_index)
