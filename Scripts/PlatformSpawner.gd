class_name PlatformSpawner extends Spawner

@export var platforms: Dictionary = {
	"scifi_bridge":{
		"scene":  preload("res://Scenes/Platform/scifi_bridge.tscn"),
		"spawn_size": 4,
		"spawn_interval_limit": {
			"min": 100.0,
			"max": 200.0
			}
	},
	"scifi_street":{
		"scene":  preload("res://Scenes/Platform/scifi_street.tscn"),
		"spawn_size": 3,
		"spawn_interval_limit": {
			"min": 300.0,
			"max": 800.0
			}
	},
	"road":{
		"scene":  preload("res://Scenes/Platform/road.tscn"),
		"spawn_size": 3,
		"spawn_interval_limit": {
			"min": 300.0,
			"max": 500.0
			}
	},
	"empty":{
		"scene": preload("res://Scenes/Platform/empty.tscn"),
		"spawn_size": 2,
		"spawn_interval_limit": {
			"min": 100.0,
			"max": 200.0
			}
	}
}
@export var light: DirectionalLight3D
@export var coin_spawner: CoinSpawner
@export var obstacle_spawner: ObstacleSpawner
@export var power_box: Node3D

@export_enum("scifi_bridge", "scifi_street", "empty", "road") var current_platform: String = "scifi_street"

enum PATTERN {
	LINEAR,
	GAP,
}
@export var pattern_switch_distance: float = 500.0  # Distance after which the pattern changes
var last_switch_distance: float = 0.0
var last_power_distance: float = 0.0

func _add_object(_amount = spawn_pool_size):
	for platform_name in platforms:
		for i in platforms[platform_name].spawn_size:
			var platform = platforms[platform_name].scene.instantiate()
			platform.name = platform_name + str(i)
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


#	_adjust_light()

func _on_game_start(data):
	super._on_game_start(data)
	_add_training_objects()

func _on_game_restart(_data):
	super._on_game_restart({})
	_add_training_objects()

func _add_training_objects():
	if GameManager.has_training:
		var platform = platforms["empty"].pool[0]
		_add_temporary_platform(platform)
	else:
		coin_spawner.spawn_object(pool[1], {}, coin_spawner.PATTERNS.LINE)
		obstacle_spawner.spawn_object(pool[1])

func set_z_position(last_platform, platform):
	platform.position.z = (platform.get_size().z * 0.5 + last_platform.get_size().z * 0.5) + last_platform.position.z

func _handle_spawn(_delta):
	if GameManager.distance - last_switch_distance > pattern_switch_distance:
		_switch_pattern()
		var limit = platforms[current_platform].get("spawn_interval_limit", spawn_interval_limit)
		pattern_switch_distance = randf_range(limit.min, limit.max)
		last_switch_distance = GameManager.distance
	elif GameManager.distance - last_power_distance > power_box.spawn_distance:
		last_power_distance = GameManager.distance
		power_box.set_spawn_distance()
		var powers = power_box.get_inactive_powers()
		if powers.is_empty():
			return
		var power = powers[0]
		power.position.x = lanes.pick_random()
		power.position.z = 250
		power.add_to_group("free")
		power.show()
		coin_spawner.pool.append(power)

func _switch_pattern():
	var current_pattern = randi() % PATTERN.size()
	
	match current_pattern:
		PATTERN.LINEAR:
			_spawn_linear()
		PATTERN.GAP:
			_spawn_gap()
	
#	_adjust_light()

func _adjust_light():
	match current_platform:
		"scifi_street":
			light.rotation_degrees.x = -90
		_:
			if light.rotation_degrees.x != 0:
				var tween = create_tween()
				tween.tween_property(light, "rotation:x", 0, 4.0)

func _spawn_linear():
	var platforms_keys = platforms.keys()
	platforms_keys.erase("empty")
	var rand_platform = platforms_keys.pick_random()
	if rand_platform == current_platform:
		return
	current_platform = rand_platform 
	var filtered_platforms = platforms[current_platform].pool

	if filtered_platforms.is_empty():
		return

	_add_to_free()

	for i in filtered_platforms.size():
		var platform = filtered_platforms[i]
		platform.position.x = 0
		set_z_position(pool.back(), platform)
		platform.show()
		pool.append(platform)
		if i == filtered_platforms.size() or i == 0:
			coin_spawner.spawn_object(platform, {}, coin_spawner.PATTERNS.LINE)
			continue
		obstacle_spawner.spawn_object(platform)
	

func _add_to_free(objects: Array = pool):
	for object in objects:
		object.add_to_group("free")

func _spawn_gap():
	var filtered_platforms = filter_by_visibility(platforms["empty"].pool, false)
	if filtered_platforms.is_empty():
		return

	for i in max(filtered_platforms.size(), randi() % 2 + 1):
		var platform = filtered_platforms[i]
		_add_temporary_platform(platform)

func _add_temporary_platform(platform, position: int = pool.size()):
	if pool.size() < position:
		print("Size exceed.")
		return
	platform.position = Vector3.ZERO
	set_z_position(pool[position - 1], platform)
	platform.add_to_group("free")
	platform.show()
	pool.insert(position, platform)

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
	if !object:
		return
	if object.position.z < -object.get_size().z:
		var recycled_platform = pool.pop_front()
		if recycled_platform.is_in_group("free"):
			_disable_object(recycled_platform, recycled_platform.position)
			recycled_platform.remove_from_group("free")
		else:
			set_z_position(pool.back(), recycled_platform)
			pool.append(recycled_platform)
			obstacle_spawner.spawn_object(recycled_platform)

func _reset():
	super._reset()
	last_power_distance = 0.0
