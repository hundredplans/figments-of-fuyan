extends Control

@onready var FindSettings: Control = $BookZone/SearchMenu/FindSettings
@onready var SearchMenu: Control = $BookZone/SearchMenu
@onready var BookText: TextEdit = $BookZone/BookText
@onready var Category: Control = $SelectCategory/Categories
@onready var Books: Control = $SelectBook/Books

var old_replaced_text: String
var SearchNode: LineEdit
var has_changed_select_search: bool = false
var search_enum: int = 0
var replace_text: String = ""

var find_string_dictionary: Dictionary = {
	"FindInText": on_find_text_submitted,
	"FindInFiles": on_find_files_text_submitted,
	"ReplaceInText": on_replace_text_submitted,
}

const static_lore: String = "res://static/lore_books/"
const temp_lore: String = "user://save/temp/lore_books/"
var selected_category: String
var selected_book: String
var book_mode: int = 0
var old_text: String

const book_font_sizes: Array = [16, 20, 24, 28, 32, 36]
var scroll_inputs: Dictionary = {
	"MouseDown": -1,
	"MouseUp": 1,
	}

var inputs: Dictionary = {
	"DownArrow": ["book", "up"],
	"LeftArrow": ["category", "down"],
	"UpArrow": ["book", "down"],
	"RightArrow": ["category", "up"],
	}

signal load_world

func _ready():
	BookText["theme_override_font_sizes/font_size"] = book_font_sizes[Settings.book_font_size]
	SearchMenu.visible = false
	all_categories = DirAccess.get_directories_at(static_lore)
	on_change_category_page(0)
	load_world.emit(Node3D.new())

func _process(_delta: float) -> void:
	if !BookText.has_focus():
		for input in ["FindInFiles", "FindInText", "ReplaceInText"]:
			if Input.is_action_just_pressed(input):
				open_search_books(input)
				break
			
func _exit_tree():
	save_book(true, selected_category, "_exit")
	
func on_create_category(category_name: String) -> void:
	if Helper.is_file_name_pure(category_name) and category_name not in all_categories:
		all_categories.append(category_name)
		all_categories.sort()
		book_mode = 0
		var dir := DirAccess.open(static_lore)
		dir.make_dir(category_name)
		selected_category = category_name
		on_change_category_page(0)
		
	else: print_debug("The name: " + category_name + " isn't pure!")
	$SelectCategory/CreateCategory.release_focus()
	$SelectCategory/CreateCategory.text = ""

func on_create_book(book_name: String) -> void:
	if selected_category and Helper.create_file(static_lore + selected_category + "/", book_name, ".txt"):
		book_mode = 0
		if !selected_book:
			selected_book = book_name
			save_book()
		else:
			save_book()
			selected_book = book_name
			BookText.text = Helper.return_file_contents(static_lore + selected_category + "/" + book_name + ".txt")
			old_text = BookText.text
			save_book()
		on_change_book_page(0)
	$SelectBook/CreateBook.release_focus()
	$SelectBook/CreateBook.text = ""

func modulate_all() -> void:
	var colors: Array = [$Details/Inside.color, Color("c4383e"), Color("a23cbd"), Color("721cb2"), Color("492e1c")]
	for btn in Category.get_children():
		var color: Color = colors[0]
		if selected_category == btn.label_text:
			color = colors[4]
		btn.get_node("Background/Inside").color = color
			
	for btn in Books.get_children():
		var color: Color = colors[book_mode]
		if book_mode == 3: color = colors[2]
		if selected_book == btn.label_text:
			match book_mode:
				0: color = colors[4]
				3: color = colors[3]
		btn.get_node("Background/Inside").color = color


func on_category_selected(_selected_category: String) -> void:
	match book_mode:
		3:
			book_mode = 2
			if selected_book and !FileAccess.file_exists(static_lore + _selected_category + "/" + selected_book + ".txt"):
				BookText.text = Helper.return_file_contents(static_lore + selected_category + "/" + selected_book + ".txt")
				old_text = BookText.text
				Helper.write_to_file(static_lore + _selected_category + "/", selected_book, ".txt", BookText.text)
				Helper.delete_file(static_lore + selected_category + "/", selected_book, ".txt")
				save_book(true, _selected_category)
		_:
			save_book()
			match _selected_category:
				selected_category: selected_category = ""
				_: selected_category = _selected_category

	BookText.text = ""
	old_text = ""
	selected_book = ""
	on_change_category_page(0)
	
func on_book_selected(_selected_book: String) -> void:
	$BookZone/SearchMenu/ResultLabel.text = "0"
	save_book()
	var old_selected_book: String = selected_book
	match _selected_book:
		selected_book: selected_book = ""
		_: selected_book = _selected_book
		
	match book_mode:
		0: 
			BookText.text = Helper.return_file_contents(static_lore + selected_category + "/" + selected_book + ".txt")
			old_text = BookText.text
			if search_enum >= 4 and SearchNode != null:
				on_find_text_submitted(SearchNode.text)
		1:
			if Settings.clear_backup_files_array[Settings.clear_backup_files] != 1:
				Helper.write_to_file(temp_lore, selected_book + "_delete", ".txt", Helper.return_file_contents(static_lore + selected_category + "/" + selected_book + ".txt"))
			Helper.delete_file(static_lore + selected_category + "/", selected_book, ".txt")
			selected_book = ""
			on_change_book_page(0)
			
		2: if !(old_selected_book and selected_book): book_mode = 3
		3: if !(old_selected_book and selected_book): book_mode = 2

	if book_mode != 0:
		BookText.text = ""
		old_text = ""

	if book_mode != 1:
		modulate_all()
	
func _on_delete_books_pressed():
	selected_book = ""
	match book_mode:
		1: book_mode = 0
		_: book_mode = 1
	modulate_all()

func _on_move_books_pressed():
	selected_book = ""
	match book_mode:
		2: book_mode = 0
		_: book_mode = 2
	modulate_all()
	
func save_book(save_button_pressed:bool=false, category:String =selected_category, exit:="") -> void:
	if selected_book and selected_category:
		Helper.write_to_file(static_lore + category + "/", selected_book, ".txt", BookText.text)
		if save_button_pressed and Settings.clear_backup_files_array[Settings.clear_backup_files] != 1:
			Helper.write_to_file(temp_lore, selected_book + exit, ".txt", BookText.text)

func _on_book_text_text_changed():
	var update_old_text: bool = true
	for input in ["FindInFiles", "FindInText", "ReplaceInText"]:
		if Input.is_action_just_pressed(input):
			if BookText.has_focus():
				update_old_text = false
				BookText.text = old_text
			BookText.release_focus()
			break

	if update_old_text:
		old_text = BookText.text

func open_search_books(find_string: String) -> void:
	replace_text = ""
	reset_found_searches()
	if SearchMenu.get_child_count() <= 2 or SearchMenu.get_child(2).is_queued_for_deletion():
		$BookZone/SearchMenu/ResultLabel.text = ""
		reset_find_settings(find_string)
		SearchMenu.visible = true
		var SearchButton: Control = LineEdit.new()
		SearchMenu.add_child(SearchButton)
		SearchButton.name = find_string
		SearchButton.size = Vector2(274, SearchMenu.size.y)
		SearchButton.alignment = HORIZONTAL_ALIGNMENT_CENTER
		SearchButton.grab_focus()
		SearchNode = SearchButton
		
		var i: int = 0
		for c in find_string:
			if !Helper.is_upper(c) or i == 0: SearchButton.placeholder_text += c
			else: SearchButton.placeholder_text += " " + c
			i += 1

		SearchButton.text_submitted.connect(find_string_dictionary[find_string])
		
	else:
		var new_press: bool = !SearchMenu.has_node(find_string)
		SearchMenu.visible = new_press
		SearchMenu.get_child(2).queue_free()
		if new_press:
			open_search_books(find_string)
		else:
			search_enum = 0
			SearchNode = null
			
func reset_find_settings(search_string: String) -> void:
	
	match search_string:
		"FindInFiles", "FindInText": search_enum = 0; for child in FindSettings.get_children(): child.disabled = false
		"ReplaceInText": 
			search_enum = 3
			for child in ["WholeWords", "CaseSensitive"].map(func(x: String): return FindSettings.get_node(x)):
				child.disabled = true
			FindSettings.get_node("SearchOnStart").disabled = false
				
	match search_string:
		"FindInFiles": search_enum += 4; FindSettings.get_node("SearchOnStart").disabled = true
				
	modulate_find_settings()
	
func modulate_find_settings() -> void:
	for setting in [["WholeWords", [2, 3, 6, 7]], ["CaseSensitive", [1, 3, 5, 7]], ["SearchOnStart", [4, 5, 6, 7]]]:
		match search_enum in setting[1]:
			false: FindSettings.get_node(setting[0]).modulate = Helper.BASE
			true: FindSettings.get_node(setting[0]).modulate = Helper.RED

func reset_found_searches() -> void:
	for node in Category.get_children() + Books.get_children(): node.change_found_searches(0, 0)

func on_find_files_text_submitted(find: String) -> void:
	reset_found_searches()
	var original_book_text: String = BookText.text
	for path in Helper.return_file_names_recursive(static_lore.left(-1)):
		BookText.text = Helper.return_file_contents(path)
		var found: int = return_found_searches(find).size()
		if found > 0:
			var split: Array = path.split("/")
			Category.get_node(split[split.size() - 2]).change_found_searches(found, 2)
			if split[split.size() - 2] == selected_category:
				for book in Books.get_children():
					if book.label_text == split[split.size() - 1].left(-4):
						book.change_found_searches(found, 2)
		
	BookText.text = original_book_text
	
	if SearchNode and SearchNode.name == "FindInFiles":
		on_find_text_submitted(find)

func on_replace_text_submitted(text: String) -> void:
	match replace_text:
		"":
			on_find_text_submitted(text) 
			SearchNode.text = ""
			SearchNode.placeholder_text = "Replace Text?"
			SearchNode.grab_focus()
			
			old_replaced_text = BookText.text
			replace_text = text
		_: 
			on_replace_text(text)
			replace_text = ""
			open_search_books("ReplaceInText")
			
func on_replace_text(find: String) -> void:
	save_book(true, selected_category, "_replace")
	on_find_text_submitted(replace_text)
	for caret in range(BookText.get_caret_count()):
		if BookText.has_selection(caret):
			BookText.delete_selection(caret)
			BookText.insert_text_at_caret(find, caret)
	
	save_book()
	on_find_text_submitted(find)

func on_find_text_submitted(text: String) -> void:
	SearchNode.release_focus()
	for i in range(BookText.get_caret_count()):
		BookText.deselect(i)
	
	var search_results: Array[Vector2i]
	if text.length() > 2:
		search_results = return_found_searches(text)
		BookText.remove_secondary_carets()
		var j: int = 0
		for selection in search_results:
			var caret_index: int = 0 if j == 0 else BookText.add_caret(selection.y, selection.x)
			BookText.select(selection.y, selection.x, selection.y, selection.x + text.length(), caret_index)
			j += 1
	$BookZone/SearchMenu/ResultLabel.text = str(search_results.size())
		
func return_found_searches(find: String) -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	var new_search_enum: int = search_enum if search_enum < 4 else search_enum - 4
	var pos: Vector2i = BookText.search(find, new_search_enum, 0, 0)
	while pos != Vector2i(-1, -1):
		if pos not in result:
			result.append(pos)
			pos = BookText.search(find, new_search_enum, pos.y, pos.x + 1)
		else: pos = Vector2(-1, -1)
	return result

func _on_whole_words_pressed():
	if search_enum in [2, 3, 6, 7]: search_enum -= 2
	else: search_enum += 2
	modulate_find_settings()
	find_string_dictionary[SearchNode.name].call(SearchNode.text)

func _on_case_sensitive_pressed():
	if search_enum in [1, 3, 5, 7]: search_enum -= 1
	else: search_enum += 1
	modulate_find_settings()
	find_string_dictionary[SearchNode.name].call(SearchNode.text)

func _on_search_on_start_pressed():
	if search_enum in [4, 5, 6, 7]: search_enum -= 4
	else: search_enum += 4
	modulate_find_settings()
	find_string_dictionary[SearchNode.name].call(SearchNode.text)

func _queue_free() -> void:
	load_world.emit(null)

const MAX_PAGE_COUNT: int = 14
var book_page: int = 0
var category_page: int = 0

var all_books: Array = []
var all_categories: Array = []

var _lore_button: PackedScene = preload("res://scenes/screens/lore_books_editor/lore_book_button.tscn")

func on_change_book_page(i: int) -> void:
	old_replaced_text = ""
	$BookZone/SearchMenu/ResultLabel.text = "0"
	
	all_books = Array(DirAccess.get_files_at(static_lore + selected_category)).map(func(x: String): return x.left(-4))\
	if selected_category else []
	
	var max_page: int = floor(max(all_books.size(), 1) / MAX_PAGE_COUNT)
	book_page = clamp(book_page + i, 0, max_page)
	
	$SelectBook/PageZone/LeftArrow.disabled = book_page == 0
	$SelectBook/PageZone/RightArrow.disabled = book_page == max_page
	
	for child in $SelectBook/Books.get_children(): child.queue_free()
	var y: int = 0
	for j in range(book_page * MAX_PAGE_COUNT, min((book_page + 1) * MAX_PAGE_COUNT, all_books.size())):
		var lore_button: Control = _lore_button.instantiate()
		lore_button.label_text = all_books[j]
		Books.add_child(lore_button)
		lore_button.name = all_books[j]
		lore_button.position.y += 57 * y
		lore_button.size.x = Books.size.x
		lore_button.pressed.connect(on_book_selected.bind(lore_button.label_text))
		y += 1
	
	$SelectBook/PageZone/Amount.text = str(book_page)
	modulate_all()
	
	if SearchNode and SearchNode.name == "FindInFiles":
		on_find_files_text_submitted(SearchNode.text)
	
func on_change_category_page(i: int) -> void:
	var max_page: int = floor(max(all_categories.size(), 1) / MAX_PAGE_COUNT)
	category_page = clamp(category_page + i, 0, max_page)
	
	$SelectCategory/PageZone/LeftArrow.disabled = category_page == 0
	$SelectCategory/PageZone/RightArrow.disabled = category_page == max_page
	
	for child in $SelectCategory/Categories.get_children(): child.queue_free()
	var y: int = 0
	for j in range(category_page * MAX_PAGE_COUNT, min((category_page + 1) * MAX_PAGE_COUNT, all_categories.size())):
		var lore_button: Control = _lore_button.instantiate()
		lore_button.label_text = all_categories[j]
		Category.add_child(lore_button)
		lore_button.position.y += 57 * y
		lore_button.size.x = Category.size.x
		lore_button.name = all_categories[j]
		lore_button.pressed.connect(on_category_selected.bind(all_categories[j]))
		y += 1
		
	$SelectCategory/PageZone/Amount.text = str(category_page)
	on_change_book_page(0)
