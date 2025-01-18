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
		"spawn_size": 1
	}
}
@export_enum("scifi_bridge", "scifi_street", "empty") var current_platform: String = "scifi_street"


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
				_disable_object(platform, Vector3(-50, 0, 0))
			platforms[platform_name].pool.append(platform)

	pool = platforms[current_platform].pool

func set_z_position(last_platform, platform):
	platform.position.z = (platform.get_size().z * 0.5 + last_platform.get_size().z * 0.5) + last_platform.position.z

func _handle_spawn(delta):
	if GameManager.distance >= 10 and GameManager.distance <= 11:
		var rand_index = randi() % pool.size()
		var object = pool[rand_index]
		if object.position.z >= object.get_size().z:
			object.position.y = -200
			print(pool[rand_index], pool[rand_index].position)

func _recycle_object(_object):
	pass

func _recycle():
	var object = pool.front()
	if object.position.z < -object.get_size().z:
		var recycled_platform = pool.pop_front()
		recycled_platform.position.y = 0
		set_z_position(pool.back(), recycled_platform)
		pool.append(recycled_platform)
