extends Node

var		server : TCPServer
const	port = 4242
var		client

const	BOX_WIDTH = 80
const	BOX_HEIGHT = 40

var	actionLabels = []
var	actionMethods = []

var	cursor_index = 0

func	respondMessage(message):
	var	timer = Timer.new()
	add_child(timer)
	timer.start(0.05)
	await timer.timeout
	client.put_data(message.to_utf8_buffer())

func	bettingHandler(message: String):
	match message:
		"RIGHT":
			if (get_node("../Player").stack >= get_node("../Player/Controls/BetActions/SpinBox").value + 2):
				get_node("../Player/Controls/BetActions/SpinBox").value += 2
				respondMessage("OK")
		"LEFT":
			if (get_node("../Player/Controls/BetActions/SpinBox").value > 2):
				get_node("../Player/Controls/BetActions/SpinBox").value -= 2
			respondMessage("OK")
		"BUTTON A":
			get_node("../Player")._on_bet_pressed()
			respondMessage("OK")
		"BUTTON B":
			respondMessage("Cashout: %d" % get_node("../Player/").stack)
			var	stack = get_node("../Player").stack
			stack -= stack % 2
			get_node("../Player").stackTransaction(-stack)

func	actionHandler(message: String):
	match message:
		"RIGHT":
			cursor_index += 1
			cursor_index %= 4
			respondMessage("OK")
		"LEFT":
			cursor_index -= 1
			if cursor_index == -1:
				cursor_index = 3
			respondMessage("OK")
		"BUTTON A":
			actionMethods[cursor_index].call()
			respondMessage("OK")
	get_node("Cursor").position = actionLabels[cursor_index].position + Vector2(-5, -5)

func	setupServer() -> void:
	server = TCPServer.new()
	if server.listen(port) == OK:
		print("Serveur TCP démarré")
	else:
		print("Erreur lors de l'ouverture du port")
	set_process(true)
func 	_process_action(action: String):
	if action == "CREDIT":
		get_node("../Player").stackTransaction(2)
		respondMessage("OK")
		return 
	match (GameManager.game_status):
		GameManager.GameState.BETTING:
			bettingHandler(action)
		GameManager.GameState.WAITING_PLAYER_ACTION:
			actionHandler(action)

func	_process(_delta):
	if server.is_connection_available():
		client = server.take_connection()
		if client:
			print("Client connecté :", client.get_connected_host())
	if client:
		if client.get_available_bytes() > 0:
			var	message = client.get_utf8_string(client.get_available_bytes()).strip_edges()
			_process_action(message)

func _ready() -> void:
	setupServer()
	actionLabels = [get_node("HitButton"), get_node("StandButton"), get_node("DoubleButton"), get_node("SplitButton")]
	actionMethods = [get_node("../Player")._on_hit_pressed, get_node("../Player")._on_stand_pressed, get_node("../Player")._on_double_pressed, get_node("../Player")._on_split_pressed]
