class_name Training extends Spawner

var init_positions

func _ready():
	pool = get_children()
	init_positions = pool.map(func(obj): return obj.position)
	GameManager.training_finish.connect(queue_free)

func _reset():
	for i in pool.size():
		pool[i].position = init_positions[i]
		pool[i].show()

func _handle_pool_reset():
	pass
