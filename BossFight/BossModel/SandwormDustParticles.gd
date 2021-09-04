extends Particles

onready var timer = $Timer

func _ready():
	emitting = true
	timer.connect("timeout", self, "queue_free")
	timer.start()
