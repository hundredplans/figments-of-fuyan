extends Control

const half_col := Color(1,1,1,0.5)
const full_col := Color(1,1,1,1)

var active_page_change: int = 0
var all_cards_path: String = "res://static_data/cards/all_cards.json"
var owned_cards_path: String = "res://static_data/cards/owned_cards.json"
var hero_clan_path: String = "res://static_data/cards/hero_clans.json"
var clan_convert_path: String = "res://static_data/cards/card_clan_to_full_clan.json"
var stat_abbreviation_path: String = "res://static_data/cards/card_stat_abbreviations.json"
var weird_letter_path: String = "res://static_data/deck_manager/weird_letter_conversion.json"
var search_aliases_path: String = "res://static_data/deck_manager/search_aliases.json"
var keyword_search_path: String = "res://static_data/deck_manager/keyword_search.json"

var active_search_cards: Array = []
var display_cards: Array = []
@onready var all_cards: Dictionary = Helper.load_json(all_cards_path)
@onready var owned_cards: Dictionary = Helper.load_json(owned_cards_path)
@onready var hero_clans: Dictionary = Helper.load_json(hero_clan_path)
@onready var clan_convert: Dictionary = Helper.load_json(clan_convert_path)
@onready var stat_abbreviation: Dictionary = Helper.load_json(stat_abbreviation_path)
@onready var weird_letter: Dictionary = Helper.load_json(weird_letter_path)
@onready var search_aliases: Dictionary = Helper.load_json(search_aliases_path)
@onready var keyword_search: Dictionary = Helper.load_json(keyword_search_path)

@onready var CardDisplay: Node2D = $Temp/CardDisplay
var close_on_input: Array = [null, null]
var alphabet_numbers: Dictionary = {
	"a": 0,
	"b": 1,
	"c": 2,
	"d": 3,
	"e": 4,
	"f": 5,
	"g": 6,
	"h": 7,
	"i": 8,
	"j": 9,
	"k": 10,
	"l": 11,
	"m": 12,
	"n": 13,
	"o": 14,
	"p": 15,
	"q": 16,
	"r": 17,
	"s": 18,
	"t": 19,
	"u": 20,
	"v": 21,
	"w": 22,
	"x": 23,
	"y": 24,
	"z": 25,}
var rarity_numbers: Dictionary = {
	"s": 0,
	"c": 1,
	"r": 2,
	"e": 3,
	"l": 4,}

var deck_manager_main_display: Dictionary = {
	"sort_type": "DeckManagerDoubleDecker",
}

var main_screen: bool = false
var max_cards_on_display: int = 10
var max_page: int = 0
var display_page: int = 0
var current_sort: int = CLAN_SORT
enum {CLAN_SORT, ENERGY_SORT, RARITY_SORT}
	
func _ready():
	set_button_state($Temp/Filters/HideHeroCards, TempData.filter_settings.hide_hero_cards.active)
	set_button_state($Temp/Filters/ShowScrapCards, TempData.filter_settings.show_scrap_cards.active)
	set_button_state($Temp/Filters/ShowUnownedCards, TempData.filter_settings.show_unowned_cards.active)
	set_button_state($Temp/Filters/EnergyFilter/Button, TempData.filter_settings.energy_filter.active)
	set_button_state($Temp/Filters/RarityFilter/Button, TempData.filter_settings.rarity_filter.active)
	set_button_state($Temp/Filters/TypeFilter/Button, TempData.filter_settings.type_filter.active)
	set_sort_button_state($Temp/SortButtons/SortClan)
func _process(_delta):
	if main_screen and $Timers/ChangePage.is_stopped():
		if !$Temp/CardSearch.has_focus():
			if Input.is_action_pressed("InputLeft"):
				_on_load_back_page()
				active_page_change = -1
				$Timers/ChangePage.start()
				
			elif Input.is_action_pressed("InputRight"): # make sure this stays an elif
				_on_load_forward_page()
				active_page_change = 1
				$Timers/ChangePage.start()
				
			elif Input.is_action_just_pressed("InputSideLeft"):
				_on_load_back_page()
				
			elif Input.is_action_just_pressed("InputSideRight"):
				_on_load_forward_page()
func on_display_cards():
	display_page = 0
	display_cards = []
	var group: Array = process_active_search()
	var aliases: Array = find_active_aliases(group)
	for card in on_sort_display_cards(all_cards.values().filter(filter_card)):
		if energy_rarity_type_filter_card(card):
			if card_match_active_search(card, group, aliases):
				display_cards.append(card)
	
	if display_cards.size() <= 0: $Temp/NoCards.add_child(load("res://screens/deck_manager/empty_cards.tscn").instantiate())
	else: for child in $Temp/NoCards.get_children(): child.queue_free()
	max_page = ceil(float(display_cards.size()) / max_cards_on_display) - 1
	on_load_page()
	
func find_active_aliases(group: Array) -> Array:
	if group.size() > 0 and group[0].size() > 0:
		return flatten(search_aliases.keys().\
		filter(func(x: String): return flatten(group).\
		any(func(y: String): return x.begins_with(y))).map(func(z: String): return search_aliases[z]))
	return []
func flatten(x: Array) -> Array:
	var f: Array = []
	for i in x: for j in i: f.append(j)
	return f
	
func process_active_search() -> Array:
	return Array($Temp/CardSearch.text.to_lower().split(";", false)).map(func(x: String): return x.split(":", false))\
	.map(func(x: Array): return x.map(func(x): return x.lstrip(" ")))\
	.map(func(x: Array): return x.filter(func(x): return x.length() > 2)).filter(func(x: Array): return x.size())\
	.filter(func(x: Array): return not (x.size() == 1 and x[0].length() == 3 and x[0][0].is_valid_int() and !("hp" in x[0])))
	
func card_match_active_search(card: Dictionary, group: Array, aliases: Array) -> bool:
	if group.size() > 0 and group[0].size() > 0:
		return group.any(func(x: Array): return x\
		.all(func(x: String): return match_active_search(card, x, aliases)))
	return true
	
func match_active_search(card: Dictionary, x: String, aliases: Array) -> bool:
	if x[0].is_valid_int():
		var abbrev: String = x.erase(0, 1)
		if stat_abbreviation.has(abbrev) and\
		card.has(stat_abbreviation[abbrev]) and\
		card[stat_abbreviation[abbrev]] == x[0].to_int(): return true
	elif [card.name, clan_convert[card.clan]].any(func(y: String): return y.to_lower().begins_with(x)): return true
	elif card.cid in aliases: return true
	elif keyword_search.keywords.any(func(y: String): if x in y: return y in card.text.to_lower()): return true
	return false
	
func search_filter_card(card: Dictionary) -> bool:
	if card in active_search_cards: return true
	return false
func energy_rarity_type_filter_card(card: Dictionary) -> bool:
	if TempData.filter_settings["energy_filter"].active:
		if card.type != "r":
			if int(card.e) > 9 and TempData.filter_settings["energy_filter"].applied.has(9): pass
			elif !TempData.filter_settings["energy_filter"].applied.has(int(card.e)): return false
		elif !TempData.filter_settings["energy_filter"].applied.has(0): return false
	if TempData.filter_settings["rarity_filter"].active:
		if card.rarity == "s": pass
		elif not (card.rarity in TempData.filter_settings["rarity_filter"].applied): return false
		
	if TempData.filter_settings.type_filter.active:
		if !TempData.filter_settings.type_filter.applied.any(func(st: String): return card.type in st): 
			return false
			
	return true
func filter_card(card: Dictionary) -> bool:
	if TempData.filter_settings["hide_hero_cards"].active: if card.clan in hero_clans.hero_clans: return false
	if !TempData.filter_settings["show_scrap_cards"].active: if card.rarity == "s": return false
	if !TempData.filter_settings["show_unowned_cards"].active:
		if !owned_cards.owned_cards.has(str(card.cid)): return false
		elif owned_cards.owned_cards[str(card.cid)][0] == 0 and card.rarity != "s": return false
	else: if !owned_cards.owned_cards.has(str(card.cid)): return false
	return true
func on_load_page():
	CardDisplay.clear_cards()
	var send_cards: Array = []
	for i in range(display_page * max_cards_on_display, (display_page + 1) * max_cards_on_display):
		if i < display_cards.size(): send_cards.append(Helper.create_max_card(display_cards[i]))
		
	CardDisplay.send_sort_cards(send_cards, deck_manager_main_display)
func _on_back_page_pressed():
	_on_load_back_page()
func _on_forward_page_pressed():
	_on_load_forward_page()
func _on_load_forward_page():
	if display_page < max_page: 
		display_page += 1
		on_load_page()
func _on_load_back_page():
	if display_page > 0: 
		display_page -= 1
		on_load_page()
func _on_hide_hero_cards_pressed():
	TempData.filter_settings.hide_hero_cards.active = !TempData.filter_settings.hide_hero_cards.active
	set_button_state($Temp/Filters/HideHeroCards, TempData.filter_settings.hide_hero_cards.active)
	on_display_cards()
func _on_show_scrap_cards_pressed():
	TempData.filter_settings.show_scrap_cards.active = !TempData.filter_settings.show_scrap_cards.active
	set_button_state($Temp/Filters/ShowScrapCards, TempData.filter_settings.show_scrap_cards.active)
	on_display_cards()
func _on_show_unowned_cards_pressed():
	TempData.filter_settings.show_unowned_cards.active = !TempData.filter_settings.show_unowned_cards.active
	set_button_state($Temp/Filters/ShowUnownedCards, TempData.filter_settings.show_unowned_cards.active)
	on_display_cards()
func set_button_state(button: Button, pressed: bool):
	var color := full_col
	if pressed: color = half_col
	button.self_modulate = color
func _on_change_page_timeout() -> void:
	if active_page_change == 1:
		if Input.is_action_pressed("InputRight"):
			_on_load_forward_page()
			$Timers/ChangePage.start()
			return
			
	elif active_page_change == -1:
		if Input.is_action_pressed("InputLeft"):
			_on_load_back_page()
			$Timers/ChangePage.start()
			return
	active_page_change = 0
func _on_energy_filter_energy_filter_changed():
	set_button_state($Temp/Filters/EnergyFilter/Button, TempData.filter_settings.energy_filter.active)
	on_display_cards()
func _on_rarity_filter_rarity_filter_changed():
	set_button_state($Temp/Filters/RarityFilter/Button, TempData.filter_settings.rarity_filter.active)
	on_display_cards()
func _on_type_filter_type_filter_changed():
	set_button_state($Temp/Filters/TypeFilter/Button, TempData.filter_settings.type_filter.active)
	on_display_cards()
func on_sort_display_cards(cards: Array):
	match current_sort:
		ENERGY_SORT: 
			return on_subsort_cards(on_subsort_cards(on_subsort_cards(on_sort_cards(cards,\
			 "e"),
			 "e", "rarity"),
			 "rarity", "clan"),
			 "clan", "cid")
			
		CLAN_SORT:
			return on_subsort_cards(on_subsort_cards(on_subsort_cards(on_sort_cards(cards,\
			 "clan"),
			 "clan", "rarity"),
			 "rarity", "e"),
			 "e", "cid")
			
		RARITY_SORT:
			return on_subsort_cards(on_subsort_cards(on_subsort_cards(on_sort_cards(cards,\
			"rarity"),
			"rarity", "e"),
			"e", "clan"),
			"clan", "cid")
func on_subsort_cards(cards: Array, fst: String, snd: String):
	var cards_size: int = cards.size()
	if cards_size > 0:
		var sub_display_cards: Array = [cards[0]]
		for i in range(1, cards_size):
			if convert_to_property(cards[i], fst) != convert_to_property(cards[i-1], fst):
				cards += on_sort_cards(sub_display_cards, snd)
				sub_display_cards.clear()
			sub_display_cards.append(cards[i])
		cards += on_sort_cards(sub_display_cards, snd)
	return cards.slice(cards_size)
func _on_sort_energy_pressed():
	if current_sort != ENERGY_SORT:
		current_sort = ENERGY_SORT
		on_display_cards()
	set_sort_button_state($Temp/SortButtons/SortEnergy)
func _on_sort_clan_pressed():
	if current_sort != CLAN_SORT:
		current_sort = CLAN_SORT
		on_display_cards()
	set_sort_button_state($Temp/SortButtons/SortClan)
func _on_sort_rarity_pressed():
	if current_sort != RARITY_SORT:
		current_sort = RARITY_SORT
		on_display_cards()
	set_sort_button_state($Temp/SortButtons/SortRarity)
func set_sort_button_state(button: Button):
	for b in [$Temp/SortButtons/SortEnergy, $Temp/SortButtons/SortClan, $Temp/SortButtons/SortRarity]:
		if b != button: set_button_state(b, false)
		else: set_button_state(b, true)
func on_sort_cards(cards: Array, property: String) -> Array:
	for i in range(1, cards.size()):
		var key_item: Dictionary = cards[i]
		var j: int = i - 1
		while j >= 0 and convert_to_property(cards[j], property) > convert_to_property(key_item, property):
			cards[j + 1] = cards[j]
			j -= 1
		cards[j + 1] = key_item
		
	return cards
func convert_to_property(card: Dictionary, property: String):
	match property:
		"e": return 0 if card.type == "r" else card.e
		"clan": return alphabet_numbers[card.clan]
		"rarity": return rarity_numbers[card.rarity]
		"cid": return card.cid

func _on_card_search_text_changed(__):
	$Timers/SearchLoadPage.start()
	
func _on_card_search_text_submitted(__: String):
	$Temp/CardSearch.release_focus()

func _on_search_load_page_timeout():
	on_display_cards()
