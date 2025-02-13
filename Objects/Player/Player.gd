extends Node

const	MAX_BET = 150000

var	hands_scene = preload("res://Objects/Hand/Hand.tscn")
var	hands = [] # Ajouter une hand par défaut
var	current_hand = 0
var	stack = 1500000
var	wager = 0

# AJOUTER UNE VERIFICATION DU POGNON ON_BET_PRESSED

func	_on_bet_pressed() -> void:
	wager = get_node("./Controls/BetActions/SpinBox").value
	if wager > stack:
		return
	get_node("./Controls/BetActions").visible = false
	stackTransaction(-wager)
	GameManager.changeGameStatus(GameManager.GameState.DEALING_HAND)
func	reset_cards() -> void:
	for hand in hands:
		hand.queue_free()
	hands.clear()
	hands.append(hands_scene.instantiate())
	add_child(hands[0])
	get_node("../../Main").resize()
	current_hand = 0
func	betting_phase() -> void:
	get_node("./Controls/Actions").visible = false
	get_node("./Controls/BetActions").visible  = true
	get_node("./Controls/BetActions/SpinBox").value = 2
	get_node("./Controls/BetActions/SpinBox").max_value = min(stack, MAX_BET)

func 	stackTransaction(value: int):
	stack += value
	get_node("./Stack").text = "%d" % [stack]
	get_node("./Controls/BetActions/SpinBox").max_value = min(stack, 20)
	if GameManager.game_status == GameManager.GameState.WAITING_PLAYER_ACTION:
		activateButtons()

func	disableButtons() -> void:
	get_node("Controls/Actions/Hit").disabled = true
	get_node("Controls/Actions/Stand").disabled = true
	get_node("Controls/Actions/Double").disabled = true
	get_node("Controls/Actions/Split").disabled = true	
func	activateButtons() -> void:
	get_node("./Controls/Actions/Hit").disabled = false
	get_node("./Controls/Actions/Stand").disabled = false
	get_node("./Controls/Actions/Split").disabled = not (hands[current_hand].isSplittable() && hands.size() < 4 and stack >= wager)
	get_node("./Controls/Actions/Double").disabled = stack < wager or len(hands[current_hand].cards) != 2
func	_on_hit_pressed() -> void:
	disableButtons()
	await hands[current_hand].addCard(get_node("../Deck").drawCard())
	GameManager.changeGameStatus(GameManager.GameState.WAITING_PLAYER_ACTION)
	if hands[current_hand].getScore() == -1:
		_on_stand_pressed()
	activateButtons()
func	_on_stand_pressed() -> void:
	current_hand += 1
	if current_hand == hands.size():
		GameManager.changeGameStatus(GameManager.GameState.DEALER_TURN)
	else:
		await hands[current_hand].addCard(get_node("../Deck").drawCard())
		activateButtons()
		GameManager.changeGameStatus(GameManager.GameState.WAITING_PLAYER_ACTION)
func	_on_double_pressed() -> void:
	if get_node("Controls/Actions/Double").disabled:
		return
	disableButtons()
	await hands[current_hand].doubleWager()
	await hands[current_hand].addCard(get_node("../Deck").drawCard())
	stackTransaction(-wager)
	_on_stand_pressed()
func	_on_split_pressed() -> void:
	if get_node("Controls/Actions/Split").disabled:
		return
	var	new_hand = hands_scene.instantiate()
	disableButtons()
	new_hand.position = hands[hands.size() - 1].position
	new_hand.position += Vector2(100, 0)
	new_hand.setWager(wager)
	hands.append(new_hand)
	add_child(new_hand)
	var	split_card = hands[current_hand].split()
	new_hand.cards.append(split_card)
	new_hand.add_child(split_card)
	split_card.set_global_position(hands[current_hand].cards[0].global_position + Vector2(20, 0))
	create_tween().tween_property(split_card, "position", Vector2(0, 0), 0.2) # CUL
	
	# Mettre en place les nouveaux scores
	hands[current_hand].value = hands[current_hand].cards[0].getValue()
	if hands[current_hand].value == 1:
		hands[current_hand].value += 10
		hands[current_hand].soft = true
	hands[current_hand].displayScore()
	new_hand.value = new_hand.cards[0].getValue()
	if new_hand.value == 1:
		new_hand.value += 10
		new_hand.soft = true
	new_hand.displayScore()	
	await hands[current_hand].addCard(get_node("../Deck").drawCard())
	activateButtons()
	stackTransaction(-wager)
	GameManager.changeGameStatus(GameManager.GameState.WAITING_PLAYER_ACTION)
func	player_turn():
	get_node("./Controls/Actions").visible = true
	get_node("./Controls/BetActions").visible  = false
	activateButtons()

func	lock_controls():
	get_node("./Controls/Actions").visible = false

func	_on_game_status_changed(status: GameManager.GameState):
	if status == GameManager.GameState.BETTING:
		betting_phase() # RESET CARDS
	elif status == GameManager.GameState.WAITING_PLAYER_ACTION:
		player_turn()
	elif status == GameManager.GameState.DEALER_TURN:
		lock_controls()

func	_ready() -> void:
	GameManager.status_changed.connect(_on_game_status_changed)
	hands.append(hands_scene.instantiate())
	get_node("Stack").text = "%d" % [stack]
	add_child(hands[0])
