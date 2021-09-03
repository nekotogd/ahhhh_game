extends Spatial

var sway_pivot = null

export var equip_pos = Vector3.ZERO

func _ready():
	set_as_toplevel(true)
	call_deferred("create_sway_pivot")
	
	
func create_sway_pivot():
	sway_pivot = Spatial.new()
	get_parent().add_child(sway_pivot)
	sway_pivot.transform.origin = equip_pos
	sway_pivot.name = "Shotgun" + "_Sway"
	#change for multi weapons system
	
	
	
func sway(delta):
	global_transform.origin = sway_pivot.global_transform.origin
	
	var self_quat = global_transform.basis.get_rotation_quat()
	var pivot_quat = sway_pivot.global_transform.basis.get_rotation_quat()
	var new_quat = self_quat.slerp(pivot_quat, 25 * delta)
	
	global_transform.basis = Basis(new_quat)
