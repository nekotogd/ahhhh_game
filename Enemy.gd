extends KinematicBody

enum {
	IDLE,
	ALERT
	}

var state = IDLE

var target

const TURN_SPEED = 2

var health = 200
var damage = 15

onready var raycast = $RayCast
onready var eyes = $Eyes
onready var shoottimer = $ShootTimer
export var MAX_SPEED = 7
export var GRAVITY = 9.8
onready var animp = $AccursedDesertNomadFinal/AnimationPlayer
onready var smoke = $Particles
var gravity_vec = Vector3.ZERO


func _ready():
	pass
	
func _process(delta):
	
	
	
	match state:
		IDLE:
			rotate_y(0)
			animp.play("T-Pose-loop")

	if health <= 0:
		var old_transform = smoke.global_transform
		remove_child(smoke)
		get_parent().add_child(smoke)
		smoke.set_owner(get_parent())
		smoke.emitting = true
		smoke.global_transform = old_transform
		smoke.emitting = true
		queue_free()

		


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
			print("hit")
			raycast.get_collider().health -= damage
			print(hit)
			print(raycast.get_collider().health)

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
