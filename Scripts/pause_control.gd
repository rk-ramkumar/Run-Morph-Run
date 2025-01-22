extends Control


func _ready():
	hide()
	GameManager.game_pause.connect(show)

func _on_exit_button_pressed():
	get_tree().quit()


func _on_restart_button_pressed():
	GameManager.start()
	hide()


func _on_resume_button_pressed():
	GameManager.resume()
	hide()
