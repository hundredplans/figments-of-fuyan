extends Node



func _ready() -> void:
	var a: Array = [7, 12, 33, 58, 11, 8, 2, 3]
	var a_size: int = a.size()
	buildHeap(a, a_size)
	
	for i in range(a_size - 1, 0, -1):
		onSwapFirst(a, a_size)
		a_size -= 1
		maxHeapify(a, 0, a_size)

func onSwapFirst(a: Array, a_size) -> void:
	onSwap(a, 0, a_size - 1)

func maxHeapify(a: Array, index: int, a_size: int) -> void:
	var largest: int = index
	var left_index: int = getLeft(a, index)
	var right_index: int = getRight(a, index)

	if left_index == -1 and right_index == -1: return
	
	if (left_index < a_size and left_index != -1) and (a[left_index] > a[index]):
		largest = left_index
	
	if (right_index < a_size and right_index != -1) and (a[right_index] > a[largest]):
		largest = right_index
	
	if largest != index:
		onSwap(a, largest, index)
		maxHeapify(a, largest, a_size)

func onSwap(a: Array, index: int, index_two: int) -> void:
	var old_value: int = a[index]
	a[index] = a[index_two]
	a[index_two] = old_value

func getLeft(a: Array, index: int) -> int:
	var left_index: int = (index * 2) + 1
	if left_index < a.size(): return left_index
	return -1
	
func getRight(a: Array, index: int) -> int:
	var right_index: int = (index * 2) + 2
	if right_index < a.size(): return right_index
	return -1
	
func getParent(a: Array, index: int) -> int:
	var parent_index: int = floor((index - 1) / 2)
	if parent_index < a.size(): return parent_index
	return -1
	
func buildHeap(a: Array, a_size: int) -> void:
	for i in range(floor((a_size - 2) / 2), -1, -1):
		maxHeapify(a, i, a_size)
