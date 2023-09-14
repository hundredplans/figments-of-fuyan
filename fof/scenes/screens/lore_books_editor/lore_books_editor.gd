extends Control
const static_lore: String = "res://static/lore_books/"
const temp_lore: String = "user://save/temp/lore_books/"
var selected_category: String
var selected_book: String
var book_mode: int = 0
const book_font_sizes: Array = [16, 20, 24, 28, 32, 36]

func _ready():
	$BookZone/BookText["theme_override_font_sizes/font_size"] = book_font_sizes[Settings.book_font_size]
	on_refresh_categories()

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
			$BookZone/BookText.text = Helper.return_file_contents(static_lore + selected_category + "/" + book_name + ".txt")
			save_book()
		on_refresh_books()
	$SelectBook/CreateBook.release_focus()
	$SelectBook/CreateBook.text = ""

func on_refresh_books() -> void:
	var y: int = 0
	for child in $SelectBook/Books.get_children(): child.queue_free()
	for file in DirAccess.get_files_at(static_lore + selected_category):
		var lorebtn: Control = preload("res://scenes/screens/lore_books_editor/lore_book_button.tscn").instantiate()
		lorebtn.label_text = file.left(-4)
		$SelectBook/Books.add_child(lorebtn)
		lorebtn.position.y = y
		lorebtn.size.x = $SelectBook.size.x
		lorebtn.pressed.connect(on_book_selected.bind(lorebtn.label_text))
		y += 58
	modulate_all()

func on_refresh_categories() -> void:
	selected_book = ""
	var y: int = 0
	for child in $SelectCategory/Categories.get_children(): child.queue_free()
	for dir in DirAccess.get_directories_at(static_lore):
		var lorebtn: Control = preload("res://scenes/screens/lore_books_editor/lore_book_button.tscn").instantiate()
		lorebtn.label_text = dir
		$SelectCategory/Categories.add_child(lorebtn)
		lorebtn.position.y = y
		lorebtn.size.x = $SelectCategory.size.x
		lorebtn.pressed.connect(on_category_selected.bind(lorebtn.label_text))
		y += 57
		
	modulate_all()
	on_refresh_books()

func modulate_all() -> void:
	var colors: Array = [$Details/Inside.color, Color("c4383e"), Color("a23cbd"), Color("721cb2"), Color("492e1c")]
	for btn in $SelectCategory/Categories.get_children():
		var color: Color = colors[0]
		if selected_category == btn.label_text:
			color = colors[4]
		btn.get_node("Background/Inside").color = color
			
	for btn in $SelectBook/Books.get_children():
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
				$BookZone/BookText.text = Helper.return_file_contents(static_lore + selected_category + "/" + selected_book + ".txt")
				Helper.write_to_file(static_lore + _selected_category + "/", selected_book, ".txt", $BookZone/BookText.text)
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
		
	$BookZone/BookText.text = ""
	selected_book = ""
	on_refresh_books()
	
func on_book_selected(_selected_book: String) -> void:
	save_book()
	var old_selected_book: String = selected_book
	match _selected_book:
		selected_book: selected_book = ""
		_: selected_book = _selected_book
		
	match book_mode:
		0: $BookZone/BookText.text = Helper.return_file_contents(static_lore + selected_category + "/" + selected_book + ".txt")
		1:
			if Settings.clear_backup_files_array[Settings.clear_backup_files] != 1:
				Helper.write_to_file(temp_lore, selected_book + "_delete", ".txt", Helper.return_file_contents(static_lore + selected_category + "/" + selected_book + ".txt"))
			Helper.delete_file(static_lore + selected_category + "/", selected_book, ".txt")
			selected_book = ""
			on_refresh_books()
			
		2: if !(old_selected_book and selected_book): book_mode = 3
		3: if !(old_selected_book and selected_book): book_mode = 2

	if book_mode != 0:
		$BookZone/BookText.text = ""

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
		Helper.write_to_file(static_lore + category + "/", selected_book, ".txt", $BookZone/BookText.text)
	
		if save_button_pressed and Settings.clear_backup_files_array[Settings.clear_backup_files] != 1:
			Helper.write_to_file(temp_lore, selected_book + exit, ".txt", $BookZone/BookText.text)
