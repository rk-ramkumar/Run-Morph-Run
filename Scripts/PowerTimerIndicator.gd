extends VBoxContainer

@onready var label = $Label
@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

func _ready():
	hide()

func start(time_sec):
	show()
	progress_bar.max_value = time_sec
	progress_bar.value = time_sec
	_update_label()
	timer.start()

func stop():
	timer.stop()
	hide()

func add_time(time_sec):
	progress_bar.max_value += time_sec
	progress_bar.value += time_sec 
	_update_label()
 
func _on_timer_timeout():
	progress_bar.value -= timer.wait_time
	_update_label()

func _update_label():
	label.text = str(progress_bar.value) + " s"
