extends Area

var DAMAGE

onready var ap = $AnimationPlayer

func _on_GroundHitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.health -= DAMAGE
		ap.stop()
		queue_free()
