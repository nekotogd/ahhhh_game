extends KinematicBody

var damage = 20
var spread = 10
var cooldown_timer := Timer.new()
var can_reload : bool = true

var health = 100 setget health_changed

var speed = 13
var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump = 10
var full_contact = false

var mouse_sensitivity = 0.09

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

const SWAY = 40
const VSWAY = 50

onready var head = $Head
onready  var hand = $Head/Hands
onready var handloc = $Head/HandLoc
onready var ground_check = $GroundCheck

onready var ray_container = $Head/Headbob/Camera/RayContainer

onready var anim = $Head/Headbob/Camera/AnimationPlayer

func _ready():
	hand.set_as_toplevel(true)
	call_deferred("add_child", cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", self, "reset_cooldown")
	randomize()
	for r in ray_container.get_children():
		r.cast_to.x = rand_range(spread, -spread)


	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func health_changed(new_health):
	if new_health <= (health - 5):
		anim.play("Pain")
	health = new_health
	if new_health <= 0:
		print("dead")
		get_tree().quit()

func reset_cooldown():
	can_reload = true


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
		
	
func fire_shotgun():
	if Input.is_action_just_pressed("fire"):
		for r in ray_container.get_children():
			r.cast_to.x = rand_range(spread, -spread)
			r.cast_to.y = rand_range(spread, -spread)
			if r.is_colliding():
				if r.get_collider().is_in_group("Enemy"):
					#print("hit enemy")
					r.get_collider().health -= damage
func _process(delta):
	if can_reload:
		cooldown_timer.start(5.0)
		can_reload = false
	fire_shotgun()
	hand.global_transform.origin = handloc.global_transform.origin
	hand.rotation.y = lerp_angle(hand.rotation.y, rotation.y, SWAY * delta)
	hand.rotation.x = lerp_angle(hand.rotation.x, head.rotation.x, VSWAY * delta)
	
	if direction == Vector3.ZERO:
		$AnimationPlayer.play("Idle")
	else:
		$AnimationPlayer.play("Headbob")
	
func _physics_process(delta):
	
	direction = Vector3()
	
	if ground_check.is_colliding():
		full_contact = true
	else:
		full_contact = false
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vec = Vector3.UP * jump
	
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("right"): 
		direction += transform.basis.x
		
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed,h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector3.UP)
		


func _on_Timer_timeout():
	can_reload = false
