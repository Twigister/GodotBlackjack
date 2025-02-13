extends Node2D

func	resize() -> void:
	var window_size = DisplayServer.window_get_size()
	var	felt = get_node("Felt")

	# resize the felt to match screen size
	felt.scale.x = window_size.x / float(felt.texture.get_width())
	felt.scale.y = window_size.y / float(felt.texture.get_height())

	# Set Dealer position
	get_node("Dealer").position = Vector2(window_size.x / 2 - 24, window_size.y / 10)
	get_node("Player").hands[0].position = Vector2(window_size.x / 2 - 24, window_size.y * 7 / 10)

func	dealHand() -> void:
	get_node("Dealer/Hand").reset()
	get_node("Player").reset_cards()
	await get_node("Player").hands[0].setWager(get_node("Player").wager)
	GameManager.waitStatus(GameManager.GameState.DEALING_HAND)
	get_node("Player").hands[0].addCard(get_node("Deck").drawCard())
	await GameManager.waitStatus(GameManager.GameState.CARD_DEALT)
	get_node("Dealer/Hand").addCard(get_node("Deck").drawCard())
	await GameManager.waitStatus(GameManager.GameState.CARD_DEALT)
	get_node("Player").hands[0].addCard(get_node("Deck").drawCard())
	await GameManager.waitStatus(GameManager.GameState.CARD_DEALT)
	GameManager.changeGameStatus(GameManager.GameState.WAITING_PLAYER_ACTION)
func	payout() -> void:
	var	winnings = 0
	var	player_node = get_node("./Player")

	for i in range(len(player_node.hands)):
		var	hand = player_node.hands[i]
		var	method: Callable
		if hand.getScore() == 22 && get_node("Dealer/Hand").getScore() != 22:
			winnings += (hand.wager * (1 + int(hand.doubled))) * 3 / 2
			method = func(): hand.payoutStack(true)
		elif hand.getScore() == -1 or hand.getScore() < get_node("Dealer/Hand").getScore():
			winnings += 0
			method = hand.loseStack
		elif hand.getScore() == get_node("Dealer/Hand").getScore():
			winnings += hand.wager * (1 + int(hand.doubled))
		else:
			winnings += hand.wager * (1 + int(hand.doubled)) * 2
			method = func(): hand.payoutStack(false)
		if not method:
			pass
		elif i == len(player_node.hands):
			await method.call()
		else:
			method.call()
	player_node.stackTransaction(winnings)
	if get_node("Deck").cards.size() < (1 - get_node("Deck").PENETRATION) * 52 * 4: # 167 cards
		get_node("Deck").shuffle()
	GameManager.changeGameStatus(GameManager.GameState.BETTING)
	
func	handRoutine() -> void:
	await GameManager.waitStatus(GameManager.GameState.DEALING_HAND)
	dealHand()
	await GameManager.waitStatus(GameManager.GameState.DEALER_TURN)
	get_node("Dealer").playHand()
	await GameManager.waitStatus(GameManager.GameState.ROUND_END)
	payout()

func _on_status_changed(status: GameManager.GameState) -> void:
	if status == GameManager.GameState.BETTING:
		handRoutine()
func	_ready() -> void:
	resize()
	get_tree().get_root().size_changed.connect(resize)
	get_node("Deck").shuffle()
	GameManager.status_changed.connect(_on_status_changed)
	GameManager.changeGameStatus(GameManager.GameState.BETTING)
