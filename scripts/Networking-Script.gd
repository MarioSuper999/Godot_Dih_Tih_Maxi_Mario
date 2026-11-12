extends Node

signal ready_to_call
signal host_created()

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 6

var is_host : bool = false
var peer : SteamMultiplayerPeer
var current_lobby_id : int
var players_on_server : Array = []

func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)
	multiplayer.peer_connected.connect(_on_peer_connected)

func _process(_delta: float) -> void:
	Steam.run_callbacks()
func host_lobby():
	is_host = true
	Steam.createLobby(LOBBY_TYPE,MAX_MEMBERS)

func on_lobby_created(connect : int, lobby_id : int) -> void:
	if connect == Steam.RESULT_OK:
		current_lobby_id = lobby_id
		var my_steam_id : int = Steam.getSteamID()
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()

func on_lobby_joined(lobby_id : int, permissions : int, locked : bool, response : int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer

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
	is_host = false

func get_lobby_members():
	players_on_server.clear()
	var num_of_lobby_members : int = Steam.getNumLobbyMembers(current_lobby_id)
	for member in range(0,num_of_lobby_members):
		var member_steam_id : int = Steam.getLobbyMemberByIndex(current_lobby_id,member)
		var member_steam_name : String = Steam.getFriendPersonaName(member_steam_id)
		players_on_server.append({"steam_id" : member_steam_id, "steam_name" : member_steam_name})

func _on_peer_connected(id : int):
	var steam_peer : SteamMultiplayerPeer = multiplayer.multiplayer_peer
	if steam_peer:
		var player_steam_id = steam_peer.get_steam_id_for_peer_id(id)
		ready_to_call.emit()
		print("hi mwommy")

func on_join_requested(lobby_id : int, steam_id : int) -> void:
	Steam.joinLobby(lobby_id)
