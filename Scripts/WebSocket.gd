extends Node

const URL: String = "wss://alterdash-server.glitch.me/"
var socket: WebSocketPeer = WebSocketPeer.new()
var is_host: bool = false
var room_id: String
var last_sent_distance = 0
var update_timer = 0
var retry_count = 0
var room_tween

signal room_created(msg:Dictionary)
signal error(msg:Dictionary)
signal player_joined(msg:Dictionary)
signal game_stated()
signal leaderboard_updated()

func _ready():
	socket.handshake_headers = ["User-Agent: alterdash/1.0"]
	socket.connect_to_url(URL)
	socket.poll()
	set_process(false)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	
	match state:
		WebSocketPeer.STATE_OPEN:
			update_timer += delta
			if update_timer >= 0.2: # Every 200ms
				update_timer = 0
				if abs(GameManager.distance - last_sent_distance) > 5:
					send_distance_update()
			while socket.get_available_packet_count() > 0:
				var msg = JSON.parse_string(socket.get_packet().get_string_from_utf8())
				match msg.type:
					"room_created":
						room_created.emit(msg)
						print(msg.room_id)
					"error":
						error.emit(msg)
						prints("ERROR", msg.message)
					"player_joined":
						player_joined.emit(msg)
						print(msg.room_size)
					"leaderboard_updated":
						leaderboard_updated.emit(msg)
						print(msg.place)
					"game_stated":
						game_stated.emit()
						print('game_stated')
		WebSocketPeer.STATE_CLOSED:
			var code = socket.get_close_code()
			var reason = socket.get_close_reason()
			print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			set_process(false)


func send_distance_update():
	last_sent_distance = GameManager.distance
	var data = { "type": "update_leaderboard", "distance": GameManager.distance }
	socket.put_packet(JSON.stringify(data).to_utf8_buffer())

func create_room(attempt = 0):
	var state = socket.get_ready_state()
	match state:
		WebSocketPeer.STATE_CLOSED:
			error.emit({"message": 'The connection is not yet open.'})

		WebSocketPeer.STATE_CONNECTING:
			if attempt != 0:
				return
			error.emit({"message": 'Connecting...'})
			room_tween = create_tween()
			room_tween.tween_method(retry, 1, 5, 5)

		WebSocketPeer.STATE_OPEN:
			if room_tween:
				room_tween.kill()
			socket.connect_to_url(URL)
			is_host = true
			var data = { "type": "create_room" , "profile": GameManager.get_profile()}
			socket.put_packet(JSON.stringify(data).to_utf8_buffer())

func retry(attempt):
	create_room(attempt)

func join_room(code):
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		error.emit({"message": 'The connection is not yet open.'})
		return
	var data = { "type": "join_room", "room_id": code , "profile": GameManager.get_profile()}
	socket.put_packet(JSON.stringify(data).to_utf8_buffer())

func start_game():
	socket.put_packet(JSON.stringify({"type": "start_game" }).to_utf8_buffer())

func listen():
	set_process(true)

func stop_listen():
	socket.close(13, "Match finished")
	set_process(false)
