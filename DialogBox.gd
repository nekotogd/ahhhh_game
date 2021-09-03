extends Control
var dialog = [
	'Tee hee, what are you doing in these parts.',
	'Dont you think its a wee bit, you know dangerous.',
	'Anyway, welcome to the Accursed Desert.',
	'We have marvels like; scary cursed creeps, mysterious pillars and a giant sand worm.',
	'Oh you dont know about the giant sand worm.',
	'Its just this huge man-eating worm around the cliff',
	'You know its the last of its species',
	'Im getting tired now, I wish those accursed creeps didnt bury me here.',
	'Goodbye now i shall rest'
]

var dialog_index = 0
var finished = false

func _ready():
	load_dialog()

func _physics_process(delta):
	$"Ind".visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		load_dialog()

func load_dialog():
	if dialog_index < dialog.size():
		finished = false
		$RichTextLabel.bbcode_text = dialog[dialog_index]
		$RichTextLabel.percent_visible = 0
		$Tween.interpolate_property(
			$RichTextLabel, "percent_visible",  0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
	else:
		queue_free()
	dialog_index += 1

func _on_Tween_tween_completed(object, key):
	finished = true
