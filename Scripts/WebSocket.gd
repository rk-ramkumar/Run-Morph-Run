extends Node

var socket = WebSocketPeer.new()
var is_host = false
var room_id

func _ready():
	socket.connect_to_url("ws://example.com")

func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	
	match state:
		WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count() > 0:
				var msg = JSON.parse_string(socket.get_packet().get_string_from_utf8())
				match msg.type:
					"room_created":
						print(msg.room_id)
					"error":
						prints("ERROR", msg.message)
					"player_joined":
						print(msg.room_size)
					"leaderboard_update":
						print(msg.leaderboard)

func create_room():
	is_host = true
	var data = { "type": "create_room" }
	socket.put_packet(JSON.stringify(data).to_utf8_buffer())

func join_room(code):
	var data = { "type": "join_room", "room_id": code }
	socket.put_packet(JSON.stringify(data).to_utf8_buffer())
