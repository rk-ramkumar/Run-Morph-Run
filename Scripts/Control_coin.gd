extends PanelContainer

@onready var label = $HBoxContainer/Label

func _ready():
	GameManager.coins_changed.connect(_update_label)
	_update_label(GameManager.coin)

func _update_label(value):
	label.text = str(value)
