extends KinematicBody

export var MAX_SPEED = 20
export var MAX_HEALTH = 100
export var GROUND_LEVEL = 0
export var DAMAGE = 15
export var AGGRO_RANGE = 64.0

var player : KinematicBody
var health : int setget health_changed
var dust_particles = preload("res://BossFight/BossModel/SandwormDustParticles.tscn")
var state = "follow"
var jump_path = preload("res://BossFight/JumpPath.tscn")
var ground_hitbox = preload("res://BossFight/GroundHitbox.tscn")

onready var skeleton = $SandWormModel/Armature/Skeleton
onready var bone_dict = {
	1 : skeleton.find_bone("Bone"),
	2 : skeleton.find_bone("Bone.001"),
	3 : skeleton.find_bone("Bone.002"),
	4 : skeleton.find_bone("Bone.003"),
	5 : skeleton.find_bone("Bone.004"),
	6 : skeleton.find_bone("Bone.005"),
	7 : skeleton.find_bone("Bone.007"),
	8 : skeleton.find_bone("Bone.008")
}

func _ready():
	set_process(false)
	var arr = get_tree().get_nodes_in_group("Player")
	if arr.size() > 0:
		player = arr[0]

func _physics_process(delta):
	match state:
		"follow":
			follow_player()
		"jump":
			if follow_path($Path):
				$Path.queue_free()
				state = "follow"

func follow_player():
	if is_instance_valid(player):
		smooth_look(player.global_transform.origin)
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		if distance > AGGRO_RANGE:
			var pos = player.global_transform.origin
			pos.y = GROUND_LEVEL
			move_to_point(player.global_transform.origin)
		else:
			state = "jump"
			var jp = jump_path.instance()
			add_child(jp, true)
			jp.set_as_toplevel(true)
			jp.name = "Path"
			jp.visible = false
			jp.look_at_from_position(global_transform.origin, player.global_transform.origin, Vector3.UP)
			jp.global_transform.origin = global_transform.origin
	else:
		var arr = get_tree().get_nodes_in_group("Player")
		if arr.size() > 0:
			player = arr[0]

func timer_state_chooser():
	if is_instance_valid(player):
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		if distance < AGGRO_RANGE:
			state = "jump"
			var jp = jump_path.instance()
			add_child(jp, true)
			jp.set_as_toplevel(true)
			jp.name = "Path"
			jp.visible = false
			var ground_level_pos : Vector3 = player.global_transform.origin
			ground_level_pos.y = GROUND_LEVEL
			jp.look_at_from_position(global_transform.origin, ground_level_pos, Vector3.UP)
			jp.global_transform.origin = global_transform.origin

func health_changed(value):
	health = value
	
	var dp = dust_particles.instance()
	get_tree().current_scene.add_child(dp)
	dp.scale *= scale
	dp.global_transform.origin = global_transform.origin
	
	if health <= 0:
		queue_free()

func smooth_look(pos : Vector3, speed : float = 0.3):
	var original_rot = rotation
	look_at(pos, Vector3.UP)
	var new_rot = rotation
	var lerped_rot = Vector3(
		lerp_angle(original_rot.x, new_rot.x, speed),
		lerp_angle(original_rot.y, new_rot.y, speed),
		lerp_angle(original_rot.z, new_rot.z, speed))
	rotation = lerped_rot

func math_bend_to_path():
	var arr_transforms : Dictionary = $Path.get_paths_transforms()
	for i in range(bone_dict.size()):
		i += 1
		var a : Transform = arr_transforms[i] # is a global_transform
		var t : Transform = Transform()
		t = a
		t.origin = skeleton.to_local(a.origin)
		skeleton.set_bone_global_pose_override(bone_dict[i], t, 1.0)

func follow_path(path : Path):
	var arr : PoolVector3Array = path.curve.get_baked_points()
	if arr.size() > 0:
		var next_pos : Vector3 = arr[0]
		next_pos = path.to_global(next_pos)
		var distance = global_transform.origin.distance_to(next_pos)
		if distance < 5:
			path.curve.remove_point(0)
			arr = path.curve.get_baked_points()
			if arr.size() > 0:
				next_pos = arr[0]
		else:
			smooth_look(next_pos, 0.1)
		move_to_point(next_pos)
	else:
		var dp = dust_particles.instance()
		get_tree().current_scene.add_child(dp)
		dp.global_transform.origin = global_transform.origin
		
		var gh = ground_hitbox.instance()
		gh.DAMAGE = DAMAGE
		get_tree().current_scene.add_child(gh)
		gh.global_transform.origin = global_transform.origin
		
		return true

func move_to_point(point : Vector3):
	var pos := global_transform.origin
	var direction : Vector3 = pos.direction_to(point)
	# warning-ignore:return_value_discarded
	move_and_slide(direction * MAX_SPEED)
