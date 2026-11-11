extends Node

signal lobby_created

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 6
const PACKET_READ_LIMIT : int = 32

var is_host = false
var peer : SteamMultiplayerPeer
var current_lobby_id : int = 0
var players_on_server : Array = []


func _ready() -> void:
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.p2p_session_request.connect(on_p2p_session_request)

func _process(_delta: float) -> void:
	if current_lobby_id > 0:
		read_all_p2p_packets()

func host_lobby():
	if current_lobby_id == 0:
		is_host = true
		Steam.createLobby(LOBBY_TYPE,MAX_MEMBERS)

func on_lobby_created(connect : int, lobby_id : int) -> void:
	if connect == Steam.RESULT_OK:
		current_lobby_id = lobby_id
		get_tree().change_scene_to_file("res://scenes/Menus/multiplayer_lobby.tscn")
		Steam.setLobbyJoinable(lobby_id, true)
		Steam.setLobbyData(lobby_id,"name","hmm")
		print("CREATED LOBBY: ", lobby_id)
		lobby_created.emit()
		var set_relay : bool = Steam.allowP2PPacketRelay(true)

func join_lobby(lobby_id):
	Steam.joinLobby(lobby_id)

func on_lobby_joined(lobby_id : int, _permissions : int, _locked : bool, response : int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		current_lobby_id = lobby_id
		make_p2p_handshake()

func on_lobby_left():
	if is_host:
		if players_on_server.size() > 1:
			var next_host_id = Steam.getLobbyMemberByIndex(current_lobby_id,1)
			Steam.setLobbyOwner(current_lobby_id,next_host_id)
	Steam.leaveLobby(current_lobby_id)
	for steam_id in players_on_server:
		if steam_id["steam_id"] != Steam.getSteamID():
			Steam.closeP2PSessionWithUser(steam_id["steam_id"])
	current_lobby_id = 0

func get_lobby_members():
	players_on_server.clear()
	var num_of_lobby_members : int = Steam.getNumLobbyMembers(current_lobby_id)
	for member in range(0,num_of_lobby_members):
		var member_steam_id : int = Steam.getLobbyMemberByIndex(current_lobby_id,member)
		var member_steam_name : String = Steam.getFriendPersonaName(member_steam_id)
		players_on_server.append({"steam_id" : member_steam_id, "steam_name" : member_steam_name})

func send_p2p_packet(this_target : int, packet_data : Dictionary, send_type : int = 0):
	var channel : int = 0
	var this_data : PackedByteArray
	this_data.append_array(var_to_bytes(packet_data))
	if this_target == 0:
		if players_on_server.size() > 1:
			for member in players_on_server:
				if member["steam_id"] != Steam.getSteamID():
					Steam.sendP2PPacket(member["steam_id"], this_data, send_type, channel)
	else:
		Steam.sendP2PPacket(this_target, this_data, send_type, channel)

func on_p2p_session_request(remote_id : int):
	var this_requester : String = Steam.getFriendPersonaName(remote_id)
	Steam.acceptP2PSessionWithUser(remote_id)

func make_p2p_handshake():
	send_p2p_packet(0, {"message" : "handshake", "steam_id" : Steam.getSteamID(), "username": Steam.getPersonaName()})

func read_all_p2p_packets(read_count : int = 0):
	if read_count >= PACKET_READ_LIMIT:
		return
	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func read_p2p_packet():
	var packet_size  : int = Steam.getAvailableP2PPacketSize(0)
	if packet_size > 0:
		var this_packet : Dictionary = Steam.readP2PPacket(packet_size,0)
		var packet_sender : int = this_packet["remote_steam_id"]
		var packet_code : PackedByteArray = this_packet["data"]
		var readable_data : Dictionary = bytes_to_var(packet_code)
		if readable_data.has("message"):
			match readable_data["message"]:
				"handshake":
					print("PLAYER: ", readable_data["username"], " HAS JOINED")
					get_lobby_members()
