class_name Training extends Spawner

var init_positions

func _ready():
	pool = get_children()
	init_positions = pool.map(func(obj): return obj.position)
	GameManager.training_finish.connect(queue_free)
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_restart)
	GameManager.request_home.connect(_on_request_home)

func _on_request_home():
	_reset("hide")
	set_process(false)

func _on_game_start(_data):
	set_process(true)
	_reset()

func _reset(visibility: String = "show"):
	for i in pool.size():
		pool[i].position = init_positions[i]
		pool[i][visibility].call()

func _handle_pool_reset():
	pass
