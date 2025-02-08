extends VBoxContainer

@onready var label = $Label
@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

func _ready():
	hide()

func start(time_sec):
	show()
	_update_label(time_sec)
	progress_bar.max_value = time_sec
	progress_bar.value = time_sec
	timer.start()

func stop():
	timer.stop()
	hide()

func add_time(time_sec):
	progress_bar.max_value += time_sec
	progress_bar.value += time_sec 
	_update_label(progress_bar.value)
 
func _on_timer_timeout():
	progress_bar.value -= timer.wait_time
	_update_label(progress_bar.value)

func _update_label(text):
	label.text = str(int(text)) + " s"
