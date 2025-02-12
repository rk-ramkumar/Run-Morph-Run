extends Node

@onready var swipe_audio_stream_player = $SwipeAudioStreamPlayer
@onready var car_audio_stream_player = $CarAudioStreamPlayer


func play_swipe_sfx():
	swipe_audio_stream_player.play()

func play_car_sfx():
	car_audio_stream_player.play()

func stop_car_sfx():
	car_audio_stream_player.stop()
