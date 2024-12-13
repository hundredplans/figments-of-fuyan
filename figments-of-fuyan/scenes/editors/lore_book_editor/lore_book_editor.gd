extends Node

@export var categories_label_settings: LabelSettings
@export var lore_book_label_settings: LabelSettings

@export var PanelButtonPacked: PackedScene

@export var book_base_script: GDScript
@export var book_base_data: GDScript

@onready var Categories: Container = %Categories
@onready var Books: Container = %Books
@onready var ActiveCategoryLabel: Label = %ActiveCategoryLabel
@onready var ActiveBookLabel: Label = %ActiveBookLabel
@onready var LoreBookTextEdit: TextEdit = %LoreBookTextEdit
@onready var BookNameEdit: LineEdit = %BookNameEdit

var active_category: LoreBookInfo.Categories
var active_book: LoreBookInfo

func _ready() -> void:
	for category in LoreBookInfo.Categories.values():
		if category == LoreBookInfo.Categories.Null: continue
		var category_name: String = LoreBookInfo.getCategoryString(category)
		var PanelButton: Control = PanelButtonPacked.instantiate()
		PanelButton.text = category_name
		PanelButton.label_settings = categories_label_settings
		PanelButton.theme_type_variation = "WhitePanelContainer"
		PanelButton.pressed.connect(onCategoryPressed.bind(category))
		Categories.add_child(PanelButton)

func onCategoryPressed(category: LoreBookInfo.Categories) -> void:
	if active_category == category: # Disable
		active_category = LoreBookInfo.Categories.Null
	else:
		active_category = category
		
	ActiveCategoryLabel.text = "Category: " + LoreBookInfo.getCategoryString(active_category)
	onRefreshBooks()
		
func onRefreshBooks() -> void:
	for child in Books.get_children(): child.queue_free()
	
	if active_category == LoreBookInfo.Categories.Null: return
	for lore_book_info in Helper.getFofInfoArray(LoreBookInfo).filter(func(x: LoreBookInfo): return x.category == active_category):
		var PanelButton: Control = PanelButtonPacked.instantiate()
		PanelButton.text = lore_book_info.name
		PanelButton.label_settings = lore_book_label_settings
		PanelButton.pressed.connect(onLoreBookPressed.bind(lore_book_info))
		Books.add_child(PanelButton)
		
func onLoreBookPressed(lore_book_info: LoreBookInfo) -> void:
	if lore_book_info == active_book:
		active_book = null
		setBookName("")
		LoreBookTextEdit.text = ""
	else:
		onSave()
		ActiveBookLabel.text = "Book: " + lore_book_info.name
		active_book = lore_book_info
		LoreBookTextEdit.text = active_book.text

func onSave() -> void:
	if active_book == null or active_book.name == "EmptyBook": return
	active_book.text = LoreBookTextEdit.text
	if active_book.resource_path.is_empty():
		active_book.resource_path = "res://resources/fof/lore_books/" + active_book.name.to_lower() + ".tres"
		active_book.gdscript = book_base_script
		active_book.saved_data = book_base_data
		active_book.id = Helper.getFirstNonConsecutiveId(LoreBookInfo)
	ResourceSaver.save(active_book)

func onBookNameEditSubmitted(new_name: String):
	if !new_name.is_valid_filename() or new_name.is_empty():
		onCreateWarningLabel("Invalid filename, try again!")
		return
		
	if new_name.to_lower() in Helper.getFofInfoArray(LoreBookInfo).map(func(x: LoreBookInfo): return x.name.to_lower()):
		onCreateWarningLabel("Name taken, try again!")
		return
		
	if active_book == null: return
	setBookName(new_name)
	BookNameEdit.release_focus()
	BookNameEdit.text = ""
		
func onCreateWarningLabel(text: String) -> void:
	var label := Label.new()
	add_child(label)
	label.modulate = Color(1, 0, 0)
	label.global_position = Vector2(1920 / 2, 1080 / 2)
	label.text = text
	await get_tree().create_timer(3).timeout
	label.queue_free()
	
func onNewBookPressed() -> void:
	if active_category == LoreBookInfo.Categories.Null:
		onCreateWarningLabel("Empty category, try again!")
		return
	
	var lore_book_info: LoreBookInfo = LoreBookInfo.new()
	setBookName("EmptyBook", lore_book_info)
	lore_book_info.category = active_category
	onLoreBookPressed(lore_book_info)
	
func setBookName(book_name: String, book: LoreBookInfo = active_book) -> void:
	if book != null:
		book.name = book_name
	ActiveBookLabel.text = "Book: " + book_name
