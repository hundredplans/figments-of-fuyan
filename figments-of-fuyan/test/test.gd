extends Node

func _ready() -> void:
	var arr: Array = [5, 25, 399, 10, 30]
	#var changed: bool = true
	#while(changed):
		#changed = false
		#for i in range(1, arr.size()):
			#if (arr[i] < arr[i - 1]):
				#changed = true
				#var old_value: int = arr[i]
				#arr[i] = arr[i - 1]
				#arr[i - 1] = old_value
	quickSort(arr, 0, arr.size() - 1)
func quickSort(arr: Array, low_index: int, high_index: int) -> void:
	if low_index < high_index:
		var pivot_index: int = partition(arr, low_index, high_index)
		quickSort(arr, low_index, pivot_index - 1)
		quickSort(arr, pivot_index + 1, high_index)
		
func partition(arr: Array, low_index: int, high_index: int) -> int:
	var j: int = low_index - 1
	var pivot_value: int = arr[high_index]
	for i in range(low_index, high_index):
		if arr[i] <= pivot_value:
			low_index += 1
			var old_arr_i: int = arr[i]
			arr[i] = arr[j]
			arr[j] = arr[i]
	var old_arr_j_plus: int = arr[j + 1]
	arr[j + 1] = arr[high_index]
	arr[high_index] = old_arr_j_plus
	return j + 1
