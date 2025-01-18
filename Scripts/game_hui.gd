extends CanvasLayer

@onready var player_speed = $Control/PlayerSpeed

func update_player_label(value):
	player_speed.text = str(int(value)) + "KMH"

