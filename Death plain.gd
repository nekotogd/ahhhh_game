extends Spatial

onready var collision = $StaticBody/CollisionShape


func _ready():
	pass 
	
func _process(delta):
	if collision.is_colliding():
		var object = collision.get_collider()
		if object.is_in_group("player"):
			get_tree().quit()
