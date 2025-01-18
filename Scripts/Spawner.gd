class_name Spawner extends Node

@export var spawn_pool_size: int = 20
@export var spawn_interval: float = 3.0
@export var spawn_distance: float = 100.0
@export var player: Player
@export var object_scene: PackedScene
@export var spawn_interval_limit: Dictionary = {
	"min": 1.0,
	"max": 5.0
}
@export var lanes: Array = [-2.5, 0, 2.5]

var pool: Array = []
var spawn_timer: float = 0.0
var _init_state: Dictionary

func _ready():
	_init_state = inst_to_dict(self)
	_add_object()
	randomize()

func _add_object(amount = spawn_pool_size):
	for _i in amount:
		var object = object_scene.instantiate()
		_disable_object(object)
		add_child(object)
		pool.append(object)

func _process(delta):
	_handle_spawn(delta)
	_move_active_object(delta)
	_recycle()

func _recycle():
	pass

func _handle_spawn(delta):
	spawn_timer += delta
	if spawn_timer > spawn_interval:
		spawn_timer = 0.0
		spawn_interval = randf_range(spawn_interval_limit.min, spawn_interval_limit.max)
		_spawn_object()

func _spawn_object():
	pass

func _move_active_object(delta):
	for object in _get_active_objects():
		object.position.z -=  player.speed * delta
		_recycle_object(object)

func _get_active_objects(objects: Array = pool, visible: bool = true):
	return objects.filter(func(object): return object.visible == visible)

func _get_inactive_objects(amount: int):
	var inactive_objects = pool.filter(func(object): return !object.visible)
	if pool.size() < 25 and inactive_objects.size() < amount:
		_add_object(amount - inactive_objects.size())
		inactive_objects = pool.filter(func(object): return !object.visible)
	return inactive_objects.slice(0, min(amount, inactive_objects.size()))

func _recycle_object(object):
	if object.position.z < -5:
		_disable_object(object)

func _disable_object(object, pos: Vector3 = Vector3(0, 0, -20)):
	object.hide()
	object.position = pos

func _reset():
	spawn_timer = _init_state.spawn_timer
	spawn_distance = _init_state.spawn_distance
	spawn_pool_size = _init_state.spawn_pool_size
	spawn_interval_limit = _init_state.spawn_interval_limit

func _handle_pool_reset():
	for object in pool:
		_disable_object(object)

func _notification(what):
	match what:
		NOTIFICATION_UNPAUSED:
			if GameManager.is_game_over:
				_reset()
				_handle_pool_reset()
