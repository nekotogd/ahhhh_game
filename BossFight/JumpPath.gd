extends Path

export var OFFSET_LENGTH = 0.6

var pf_dict = {}

func _ready():
	var i : int = 1
	for c in get_children():
		pf_dict[i] = get_node("PathFollow" + str(i))
		i += 1
	initial_offset()

func initial_offset():
	var current_offset = 0.0
	for pf in pf_dict.values():
		pf.offset = current_offset
		current_offset += OFFSET_LENGTH

func get_paths_transforms():
	var dict := {}
	var i : int = 1
	for c in get_children():
		dict[i] = c.global_transform
		i += 1
	return dict
