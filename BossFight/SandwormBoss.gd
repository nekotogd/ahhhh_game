extends KinematicBody

export var MAX_SPEED = 20
export var MAX_HEALTH = 100

var player : KinematicBody
var health : int setget health_changed
var dust_particles = preload("res://BossFight/BossModel/SandwormDustParticles.tscn")

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
onready var pathfollow_dict = {}
onready var head_pos = $SandWormModel/Armature/Skeleton/SkeletonIK/HeadPos
onready var ik = $SandWormModel/Armature/Skeleton/SkeletonIK

func _ready():
	var arr = get_tree().get_nodes_in_group("Player")
	if arr.size() > 0:
		player = arr[0]
	health = MAX_HEALTH

func _physics_process(delta):
	smooth_look(player.global_transform.origin)
	if is_instance_valid(player):
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		if distance > 10:
			var pos = player.global_transform.origin
			pos.y = 0
			move_to_point(player.global_transform.origin)
	else:
		player = get_tree().get_nodes_in_group("Player")[0]

func health_changed(value):
	health = value
	
	var dp = dust_particles.instance()
	get_tree().current_scene.add_child(dp)
	dp.global_transform.origin = global_transform.origin
	
	if health <= 0:
		queue_free()

func smooth_look(pos : Vector3):
	var original_rot = rotation
	look_at(pos, Vector3.UP)
	var new_rot = rotation
	var lerped_rot = Vector3(
		lerp_angle(original_rot.x, new_rot.x, 0.3),
		lerp_angle(original_rot.y, new_rot.y, 0.3),
		lerp_angle(original_rot.z, new_rot.z, 0.3))
	rotation = lerped_rot

func math_bend_to_path():
	var arr_transforms : Dictionary = $Path.get_paths_transforms()
	for i in range(bone_dict.size()):
		i += 1
		var a : Transform = arr_transforms[i] # is a global_transform
		var t : Transform = Transform()
		t.origin = skeleton.to_local(a.origin)
		var euler : Vector3 = a.basis.get_euler()
		t = t.rotated(Vector3.UP, euler.y)
		t = t.rotated(Vector3.RIGHT, euler.x)
		t = t.rotated(Vector3.BACK, euler.z)
		skeleton.set_bone_global_pose_override(bone_dict[i], t, 1.0)

func follow_path(path : Path):
	var arr : PoolVector3Array = path.curve.get_baked_points()
	if arr.size() > 0:
		var next_pos : Vector3 = arr[0]
		var distance = global_transform.origin.distance_to(next_pos)
		if distance < 5:
			path.curve.remove_point(0)
			arr = path.curve.get_baked_points()
			if arr.size() > 0:
				next_pos = arr[0]
		move_to_point(next_pos)
	else:
		return true

func move_to_point(point : Vector3):
	var pos := global_transform.origin
	var direction : Vector3 = pos.direction_to(point)
	# warning-ignore:return_value_discarded
	move_and_slide(direction * MAX_SPEED)
