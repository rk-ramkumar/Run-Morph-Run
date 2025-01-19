class_name PlatformSpawner extends Spawner

@export var platforms: Dictionary = {
	"scifi_bridge":{
		"scene":  preload("res://Scenes/Platform/scifi_bridge.tscn"),
		"spawn_size": 4,
	},
	"scifi_street":{
		"scene":  preload("res://Scenes/Platform/scifi_street.tscn"),
		"spawn_size": 3,
	},
	"empty":{
		"scene": preload("res://Scenes/Platform/empty.tscn"),
		"spawn_size": 2
	}
}
@export var light: DirectionalLight3D
@export_enum("scifi_bridge", "scifi_street", "empty") var current_platform: String = "scifi_bridge"

enum PATTERN {
	LINEAR,
	GAP,
}
@export var pattern_switch_distance: float = 500.0  # Distance after which the pattern changes
var last_switch_distance: float = 0.0

func _add_object(_amount = spawn_pool_size):
	for platform_name in platforms:
		for _i in platforms[platform_name].spawn_size:
			var platform = platforms[platform_name].scene.instantiate()
			add_child(platform)
			if !platforms[platform_name].has("pool"):
				platforms[platform_name].pool = []

			if !platforms[platform_name].pool.is_empty():
				var last_platform = platforms[platform_name].pool.back()
				set_z_position(last_platform, platform)
			if current_platform != platform_name:
				_disable_object(platform, platform.position)
			platforms[platform_name].pool.append(platform)

	pool = platforms[current_platform].pool.duplicate(true)
	if current_platform == "scifi_street":
		light.rotation.x = -90
	else:
		light.rotation.x = 0

func set_z_position(last_platform, platform):
	platform.position.z = (platform.get_size().z * 0.5 + last_platform.get_size().z * 0.5) + last_platform.position.z

func _handle_spawn(_delta):
	if GameManager.distance - last_switch_distance > pattern_switch_distance:
		_switch_pattern()
		pattern_switch_distance =  randf_range(spawn_interval_limit.min, spawn_interval_limit.max)
		last_switch_distance = GameManager.distance

func _switch_pattern():
	var current_pattern = 0
	
	match current_pattern:
		PATTERN.LINEAR:
			_spawn_linear()
		PATTERN.GAP:
			_spawn_gap()
	
	if current_platform == "scifi_street":
		light.rotation.x = -90
	else:
		light.rotation.x = 0

func _spawn_linear():
	var keys = platforms.keys()
	keys.erase("empty")
	var rand_name = "scifi_street"

	if rand_name == current_platform:
		return

	current_platform = rand_name
	var filtered_platforms = platforms[current_platform].pool
	if !filtered_platforms.is_empty():
		_add_to_free()
		for i in filtered_platforms.size():
			var platform = filtered_platforms[i]
			platform.position.x = 0
			set_z_position(pool.back(), platform)
			platform.show()
			pool.append(platform)

func _add_to_free(objects: Array = pool):
	for object in objects:
		object.add_to_group("free")

func _spawn_gap():
	var filtered_platforms = _get_active_objects(platforms["empty"].pool, false)
	if filtered_platforms.is_empty():
		return

	for i in min(filtered_platforms.size(), randi() % 2 + 1):
		var platform = filtered_platforms[i]
		platform.position = Vector3.ZERO
		set_z_position(pool.back(), platform)
		platform.add_to_group("free")
		platform.show()
		pool.append(platform)

func _recycle_object(_object):
	pass

func _handle_pool_reset():
	pattern_switch_distance = _init_state.pattern_switch_distance
	last_switch_distance = _init_state.last_switch_distance
	current_platform = _init_state.current_platform
	for platform_name in platforms:
		for i in platforms[platform_name].pool.size():
			var platform = platforms[platform_name].pool[i]
			if i == 0:
				platform.position.z = 0
			else:
				set_z_position(platforms[platform_name].pool[i-1], platform)
			if current_platform != platform_name:
				_disable_object(platform, platform.position)
			else:
				platform.show()
	pool = platforms[current_platform].pool.duplicate(true)

func _recycle():
	var object = pool.front()
	if object.position.z < -object.get_size().z:
		var recycled_platform = pool.pop_front()
		if recycled_platform.is_in_group("free"):
			_disable_object(recycled_platform, recycled_platform.position)
			recycled_platform.remove_from_group("free")
		else:
			set_z_position(pool.back(), recycled_platform)
			pool.append(recycled_platform)
