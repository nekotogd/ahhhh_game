extends Area

var can_interact = false
var target
var TURN_SPEED = 2

onready var eyes = $Eyes
const DIALOG = preload("res://DialogBox.tscn")

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		$Label.visible = true
		can_interact = true
		target = body

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null
		$Label.visible = false
		can_interact = false

func _input(event):
	if Input.is_key_pressed(KEY_E) and can_interact == true:
		$Label.visible = false
		var dialog = DIALOG.instance()
		get_parent().add_child(dialog)

func _physics_process(delta):
	if target == null: 
		##
		return
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	rotate_y(deg2rad(eyes.rotation.y * TURN_SPEED))
