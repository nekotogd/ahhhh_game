extends KinematicBody

export var MAX_SPEED = 7
export var GRAVITY = 9.8
export var MAX_HEALTH = 200

const TURN_SPEED = 2

enum {
	IDLE,
	ALERT
	}

var state = IDLE
var target
var health = 200 setget health_changed
var damage = 15
var gravity_vec = Vector3.ZERO

onready var raycast = $RayCast
onready var eyes = $Eyes
onready var shoottimer = $ShootTimer
onready var animp = $AccursedDesertNomadFinal/AnimationPlayer
onready var smoke = $Particles
onready var healthbar = $Healthbar


func _ready():
	health = MAX_HEALTH

func _process(delta):
	match state:
		IDLE:
			rotate_y(0)
			animp.play("T-Pose-loop")
	
	animate_health()

func health_changed(value):
	health = value
	
	if health <= 0:
		var old_transform = smoke.global_transform
		remove_child(smoke)
		get_parent().add_child(smoke)
		smoke.set_owner(get_parent())
		smoke.emitting = true
		smoke.global_transform = old_transform
		smoke.emitting = true
		queue_free()

func animate_health():
	var mat : ShaderMaterial = healthbar.material_override
	var perc : float = float(health) / MAX_HEALTH
	var lerp_progress : float = mat.get_shader_param("lerp_progress")
	mat.set_shader_param("progress", perc)
	mat.set_shader_param("lerp_progress", lerp(lerp_progress, perc, 0.2))

func _on_SightRange_body_entered(body):
	if body.is_in_group("Player"):
		state = ALERT
		target = body
		shoottimer.start()


func _on_SightRange_body_exited(body):
	if body.is_in_group("Player"):
		state = IDLE
		shoottimer.stop()

func _on_ShootTimer_timeout():
	if raycast.is_colliding():
		var hit = raycast.get_collider()
		if hit.is_in_group("Player"):
			hit.health -= damage

func _physics_process(delta):
	match state:
		ALERT:
			animp.play("Zombie Running-loop")
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(eyes.rotation.y * TURN_SPEED))
			var player_location = global_transform.origin.direction_to(target.global_transform.origin)
			var snap = Vector3.ZERO
			
			if not is_on_floor():
				gravity_vec.y -= GRAVITY
				snap = -get_floor_normal()
			else:
				snap = Vector3.DOWN
				gravity_vec.y = 0
			player_location.y = gravity_vec.y
			move_and_slide_with_snap(player_location * MAX_SPEED, snap, Vector3.UP)
