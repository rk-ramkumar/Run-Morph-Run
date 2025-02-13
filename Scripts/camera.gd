extends Node3D


@export var player: Player

func _ready():
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_start)
	if player:
		player.lane_changed.connect(_on_lane_changed)

func _on_game_start(_data):
	position.x = 0

func _on_lane_changed(x_pos):
	smooth_move_camera(x_pos)

func smooth_move_camera(target_x_pos: float):
	var tween = create_tween()
	tween.tween_property(self, "position:x", target_x_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
