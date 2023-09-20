extends Control

@onready var FindSettings: Control = $BookZone/SearchMenu/FindSettings
@onready var SearchMenu: Control = $BookZone/SearchMenu
@onready var BookText: TextEdit = $BookZone/BookText
@onready var Category: Control = $SelectCategory/Categories
@onready var Books: Control = $SelectBook/Books

var SearchNode: LineEdit
var has_changed_select_search: bool = false
var search_enum: int = 0

const static_lore: String = "res://static/lore_books/"
const temp_lore: String = "user://save/temp/lore_books/"
var selected_category: String
var selected_book: String
var book_mode: int = 0
var enable_scroll: int = 0
var offset: int = 0
var old_text: String

const CHANGE_SELECT_SEARCH_DELAY: float = 0.15
const SCROLL_OFFSET: int = 150
const scroll_pixels: int = 36
const moved_button_delay: float = 0.2

var has_moved_button: bool = false
const book_font_sizes: Array = [16, 20, 24, 28, 32, 36]

var max_book_size: int = 0
var max_category_size: int = 0

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

func _ready():
	BookText["theme_override_font_sizes/font_size"] = book_font_sizes[Settings.book_font_size]
	SearchMenu.visible = false
	on_refresh_categories()

func _process(_delta: float) -> void:
	
	if !BookText.has_focus():
		for input in ["FindInFiles", "FindInText", "ReplaceInFiles", "ReplaceInText"]:
			if Input.is_action_just_pressed(input):
				open_search_books(input)
				break
	
	for input in inputs:
		if !Rect2(BookText.global_position, BookText.size).has_point(get_viewport().get_mouse_position()):
			if Input.is_action_pressed(input):
				if !has_moved_button:
					has_moved_button = true
					call("on_button_moved", inputs[input][0], inputs[input][1])
					await get_tree().create_timer(moved_button_delay).timeout
					has_moved_button = false
					return
				
		
	if enable_scroll:
		for input in scroll_inputs:
			if Input.is_action_just_pressed(input):
				call("on_container_moved", scroll_inputs[input])

func on_container_moved(i: int) -> void:
	var container: Control
	var max_position: int
	match enable_scroll:
		1: container = Category; max_position = max_category_size
		2: container = Books; max_position = max_book_size
		
	offset = container.get_child(0).position.y + (scroll_pixels * i)
	if offset >= -max_position and offset <= 0:
		for child in container.get_children():
			child.position.y += scroll_pixels * i
	
	container.queue_redraw()
	
func on_button_moved(parent: String, direction: String) -> void:
	BookText.release_focus()
	var selection: String = get("selected_" + parent)
	var parent_name: String = "Books" if parent == "book" else "Categories"
	var parent_node: Control = get_node("Select" + parent.capitalize() + "/" + parent_name)
	if selection:
		for child in parent_node.get_children():
			if child.label_text == selection:
				var i: int = child.get_index()
				var j: int = -1
				match direction:
					"down": if i != 0: j = i - 1
					"up": if i != parent_node.get_child_count() - 1: j = i + 1
				
				if j >= 0:
					call("on_" + parent + "_selected", parent_node.get_child(j).label_text)
					if get("max_" + parent + "_size") > 0: move_buttons_to_match(j, i, parent, parent_node)
				return
	else:
		if parent_node.get_child_count() > 0:
			var i: int
			match direction:
				"down": i = parent_node.get_child_count() - 1
				"up": i = 0
			
			call("on_" + parent + "_selected", parent_node.get_child(i).label_text)
			if get("max_" + parent + "_size") > 0: align_top_bottom_buttons(i, parent)
			return
			
func align_top_bottom_buttons(i: int, parent: String) -> void:
	var old_enable_scroll: int = enable_scroll
	enable_scroll = 1 if parent == "category" else 2
	var j: int
	match i:
		0: j = 1
		_: j = -1
	
	for _i in range(ceil(get("max_" + parent + "_size") / scroll_pixels)):
		on_container_moved(j)
	
	enable_scroll = old_enable_scroll
			
func move_buttons_to_match(j: int, i: int, parent: String, parent_node: Control) -> void:
	var old_enable_scroll: int = enable_scroll
	enable_scroll = 1 if parent == "category" else 2
	var scroll_direction: int = -1 if j > i else 1
	var enable_move: bool = false
	match scroll_direction:
		-1: if parent_node.get_child(j).position.y > parent_node.size.y - SCROLL_OFFSET: enable_move = true
		1: if parent_node.get_child(j).position.y < 0 + SCROLL_OFFSET: enable_move = true
		
	if enable_move:
		for m in range(7):
			on_container_moved(scroll_direction)
	
	enable_scroll = old_enable_scroll
			
func _exit_tree():
	save_book(true, selected_category, "_exit")
	
func on_create_category(category_name: String) -> void:
	if Helper.is_file_name_pure(category_name):
		book_mode = 0
		var dir := DirAccess.open(static_lore)
		dir.make_dir(category_name)
		selected_category = category_name
		on_refresh_categories()
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
		on_refresh_books()
	$SelectBook/CreateBook.release_focus()
	$SelectBook/CreateBook.text = ""

func on_refresh_books() -> void:
	$BookZone/SearchMenu/ResultLabel.text = "0"
	var y: int = 0
	for child in Books.get_children(): child.queue_free()
	for file in DirAccess.get_files_at(static_lore + selected_category):
		var lorebtn: Control = preload("res://scenes/screens/lore_books_editor/lore_book_button.tscn").instantiate()
		lorebtn.label_text = file.left(-4)
		Books.add_child(lorebtn)
		lorebtn.position.y = y
		lorebtn.size.x = $SelectBook.size.x
		lorebtn.pressed.connect(on_book_selected.bind(lorebtn.label_text))
		y += 58
		
	if Books.get_child_count() > 0:
		var last_child: Control = Books.get_child(Books.get_child_count() - 1)
		max_book_size = int(last_child.global_position.y + last_child.size.y - Books.size.y - 14)
		
	modulate_all()

func on_refresh_categories() -> void:
	selected_book = ""
	var y: int = 0
	for child in Category.get_children(): child.queue_free()
	for dir in DirAccess.get_directories_at(static_lore):
		var lorebtn: Control = preload("res://scenes/screens/lore_books_editor/lore_book_button.tscn").instantiate()
		lorebtn.label_text = dir
		Category.add_child(lorebtn)
		lorebtn.position.y = y
		lorebtn.size.x = $SelectCategory.size.x
		lorebtn.pressed.connect(on_category_selected.bind(lorebtn.label_text))
		y += 57
		
	if Category.get_child_count() > 0:
		var last_child: Control = Category.get_child(Category.get_child_count() - 1)
		max_category_size = int(last_child.global_position.y + last_child.size.y - Category.size.y - 14)
	on_refresh_books()

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
		1:
			if !DirAccess.remove_absolute(static_lore + _selected_category):
				selected_category = ""
				on_refresh_categories()
			else:
				match _selected_category:
					selected_category: selected_category = ""
					_: selected_category = _selected_category
		_:
			save_book()
			match _selected_category:
				selected_category: selected_category = ""
				_: selected_category = _selected_category

	BookText.text = ""
	old_text = ""
	selected_book = ""
	on_refresh_books()
	
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
		1:
			if Settings.clear_backup_files_array[Settings.clear_backup_files] != 1:
				Helper.write_to_file(temp_lore, selected_book + "_delete", ".txt", Helper.return_file_contents(static_lore + selected_category + "/" + selected_book + ".txt"))
			Helper.delete_file(static_lore + selected_category + "/", selected_book, ".txt")
			selected_book = ""
			on_refresh_books()
			
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

func _on_category_mouse_entered():
	if Category.get_child_count() > 15:
		enable_scroll = 1

func _on_book_mouse_entered():
	if Books.get_child_count() > 15:
		enable_scroll = 2

func _on_scroll_mouse_exited(): enable_scroll = 0

func _on_book_text_text_changed():
	var update_old_text: bool = true
	for input in ["FindInFiles", "FindInText", "ReplaceInFiles", "ReplaceInText"]:
		if Input.is_action_pressed(input):
			if BookText.has_focus():
				update_old_text = false
				BookText.text = old_text
			if Input.is_action_just_pressed(input):
				open_search_books(input)
			break
			
	if update_old_text:
		old_text = BookText.text

func open_search_books(find_string: String) -> void:
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
			
		SearchButton.text_submitted.connect(on_find_text_submitted)
	else:
		var new_press: bool = !SearchMenu.has_node(find_string)
		SearchMenu.visible = new_press
		SearchMenu.get_child(2).queue_free()
		if new_press:
			open_search_books(find_string)
		else:
			SearchNode = null
			
func reset_find_settings(search_string: String) -> void:
	
	match search_string:
		"FindInFiles", "FindInText": search_enum = 0; for child in FindSettings.get_children(): child.disabled = false
		"ReplaceInText", "ReplaceInFiles": 
			search_enum = 3
			for child in ["WholeWords", "CaseSensitive"].map(func(x: String): return FindSettings.get_node(x)):
				child.disabled = true
			FindSettings.get_node("SearchOnStart").disabled = false
				
	match search_string:
		"ReplaceInFiles", "FindInFiles": search_enum += 4; FindSettings.get_node("SearchOnStart").disabled = true
				
	modulate_find_settings()
	
func modulate_find_settings() -> void:
	for setting in [["WholeWords", [2, 3, 6, 7]], ["CaseSensitive", [1, 3, 5, 7]], ["SearchOnStart", [4, 5, 6, 7]]]:
		match search_enum in setting[1]:
			false: FindSettings.get_node(setting[0]).modulate = Helper.BASE
			true: FindSettings.get_node(setting[0]).modulate = Helper.RED

func on_find_text_submitted(text: String) -> void: # find_string is search node name
	SearchNode.release_focus()
	for i in range(BookText.get_caret_count()):
		BookText.deselect(i)
	
	var search_results: Array[Vector2i]
	if text.length() > 2:
		search_results = return_found_searches(text)
		for selection in search_results:
			var caret_index: int = BookText.add_caret(selection.y, selection.x)
			BookText.select_word_under_caret(caret_index)
		
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
	on_find_text_submitted(SearchNode.text)

func _on_case_sensitive_pressed():
	if search_enum in [1, 3, 5, 7]: search_enum -= 1
	else: search_enum += 1
	modulate_find_settings()
	on_find_text_submitted(SearchNode.text)

func _on_search_on_start_pressed():
	if search_enum in [4, 5, 6, 7]: search_enum -= 4
	else: search_enum += 4
	modulate_find_settings()
	on_find_text_submitted(SearchNode.text)
