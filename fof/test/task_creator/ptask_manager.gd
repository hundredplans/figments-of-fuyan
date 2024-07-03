extends HBoxContainer

@onready var CategoriesButton: OptionButton = %CategoriesButton
@onready var TypeButton: OptionButton = %TypeButton
@onready var DescriptionText: TextEdit = %DescriptionText
@onready var EDTText: LineEdit = %EDTText
@onready var NecessityButton: OptionButton = %NecessityButton
@onready var PTaskContainer: GridContainer = %PTaskContainer

@onready var TypeFilter: OptionButton = %TypeFilter
@onready var CategoryFilter: OptionButton = %CategoryFilter

enum {
	SORT_ID,
	SORT_EDT,
	SORT_NECESSITY
}

var sorter: int = 0
var type_filter: int = -1
var category_filter: int = -1

func _ready() -> void:
	for category in PTaskGD.Category.keys():
		CategoriesButton.add_item(category)
		CategoryFilter.add_item(category)

	for type in PTaskGD.Type.keys():
		TypeButton.add_item(type)
		TypeFilter.add_item(type)
	
	TypeFilter.selected = getTypeFilter()
	CategoryFilter.selected = getCategoryFilter()
	
	type_filter = TypeFilter.selected
	category_filter = CategoryFilter.selected
	sorter = getSorter()
	
	onRefreshPTasks()

func getSorter() -> int:
	var ptask_save: Resource = preload("res://test/task_creator/ptask_save/ptask_save.tres")
	return ptask_save.sorter

func getTypeFilter() -> int:
	var ptask_save: Resource = preload("res://test/task_creator/ptask_save/ptask_save.tres")
	return ptask_save.type_filter
	
func getCategoryFilter() -> int:
	var ptask_save: Resource = preload("res://test/task_creator/ptask_save/ptask_save.tres")
	return ptask_save.category_filter

func onSubmit():
	var i: int = 1
	const DIR_PATH: String = "user://save/ptasks/"
	while(FileAccess.file_exists(DIR_PATH + str(i) + ".tres")):
		i += 1
	
	var ptask := PTaskGD.new(CategoriesButton.selected, TypeButton.selected, DescriptionText.text, int(EDTText.text), NecessityButton.selected)
	ResourceSaver.save(ptask, DIR_PATH + str(i) + ".tres")
	onRefreshPTasks()

func onRefreshPTasks() -> void:
	const DIR_PATH: String = "user://save/ptasks/"
	for child in PTaskContainer.get_children(): child.queue_free()
	
	var ptasks: Array = []
	for file in DirAccess.get_files_at(DIR_PATH): if !file.begins_with("0"): ptasks.append(load(DIR_PATH + file))
	
	match sorter:
		SORT_EDT: ptasks.sort_custom(func(x: PTaskGD, y: PTaskGD): return x.EDT < y.EDT)
		SORT_NECESSITY: ptasks.sort_custom(func(x: PTaskGD, y: PTaskGD): return x.necessity < y.necessity)
	
	if type_filter > -1:
		ptasks = ptasks.filter(func(x: PTaskGD): return x.type == type_filter)
		
	if category_filter > -1:
		ptasks = ptasks.filter(func(x: PTaskGD): return x.category == category_filter)
	
	for ptask in ptasks:
		var ptask_scene: Control = preload("res://test/task_creator/ptask_scene.tscn").instantiate()
		PTaskContainer.add_child(ptask_scene)
		ptask_scene.setInfo(ptask)
		ptask_scene.delete.connect(onPTaskDelete.bind(ptask))
		
func onPTaskDelete(ptask: PTaskGD) -> void:
	DirAccess.remove_absolute(ptask.resource_path)
	onRefreshPTasks()

func onSortIDPressed():
	sorter = SORT_ID
	onRefreshPTasks()
	
func onSortEDTPressed():
	sorter = SORT_EDT
	onRefreshPTasks()

func onSortNecessity():
	sorter = SORT_NECESSITY
	onRefreshPTasks()

func _on_type_filter_item_selected(index):
	onSaveTypeFilter(index)
	onRefreshPTasks()
	
func _on_category_filter_item_selected(index):
	onSaveCategoryFilter(index)
	onRefreshPTasks()

func _on_refresh_filter_pressed():
	onSaveTypeFilter(-1)
	onSaveCategoryFilter(-1)
	
	onRefreshPTasks()
	
func onSaveTypeFilter(index: int) -> void:
	TypeFilter.selected = index
	type_filter = index
	var ptask_save: Resource = preload("res://test/task_creator/ptask_save/ptask_save.tres")
	ptask_save.type_filter = index
	ResourceSaver.save(ptask_save)
	
func onSaveCategoryFilter(index: int) -> void:
	CategoryFilter.selected = index
	category_filter = index
	var ptask_save: Resource = preload("res://test/task_creator/ptask_save/ptask_save.tres")
	ptask_save.category_filter = index
	ResourceSaver.save(ptask_save)
