extends Node

var	card_scene = preload("res://Objects/Card/Card.tscn")
var	chip_stack_scene = preload("res://Objects/ChipStack/ChipStack.tscn")

const	BET_START: Vector2 = Vector2(10, 500)

var	extra_stacks = []

var cards = []
var	soft: bool = false
var	value = 0
var	wager = 0
var	doubled = false

func	reset():
	for card in cards:
		card.queue_free()
	cards.clear()
	value = 0
	soft = false
	for stack in extra_stacks:
		stack.queue_free()
	extra_stacks.clear()
	get_node("Label").text = "0"

func	displayScore() -> void:
	if getScore() == 22:
		get_node("Label").text = "BlackJack"
	elif soft:
		get_node("Label").text = "%d/%d" % [value, value - 10]
	else:
		get_node("Label").text = "%d" % [value]
func	animateCard(card):
	var	temp_card = card_scene.instantiate()
	var	tween = temp_card.create_tween()

	temp_card.setValue("A", 4)
	temp_card.position = card.position
	add_child(temp_card)
	tween.tween_property(temp_card, "scale", Vector2(0, 1), 0.25)
	await tween.finished
	var	tween2 = card.create_tween()
	tween2.tween_property(card, "scale", Vector2(1, 1), 0.25)
	await tween2.finished
	temp_card.queue_free()
func	addCard(card) -> void:
	GameManager.changeGameStatus(GameManager.GameState.DEALING_CARD)
	card.position = Vector2(20 * (cards.size() % 3), 25 * int((float(cards.size()) / 3)))
	cards.append(card)
	if (card.getValue() == 1):
		if value + 11 <= 21:
			soft = true
			value += 10
	value += card.getValue()
	if soft and value > 21:
		soft = false
		value -= 10
	card.scale = Vector2(0, 1) # Cacher la carte pour préparer l'animation
	add_child(card)
	await animateCard(card)
	displayScore()
	GameManager.changeGameStatus(GameManager.GameState.CARD_DEALT)

func	split():
	var	card = cards.pop_back()

	card.get_parent().remove_child(card)
	value = 0
	return card

# Specialized getters
func	getScore() -> int:
	if value == 21 and cards.size() == 2:
		return 22
	if value > 21:
		return -1
	return value
func	isSplittable() -> bool:
	return cards.size() == 2 and cards[0].getValue() == cards[1].getValue()

# Specialized setters
func	setWager(value: int):
	var	chip_stack = get_node("ChipStack")
	wager = value
	chip_stack.generateStack(wager)
	var	final_position = chip_stack.position + Vector2(0, chip_stack.chip_count * -5)
	#print(get_node("../Hand").position)
	chip_stack.set_global_position(BET_START)
	var tween = create_tween()
	tween.tween_property(chip_stack, "position", final_position, 0.2)
	await tween.finished
	
func	doubleWager() -> void:
	var	stack = chip_stack_scene.instantiate()
	extra_stacks.append(stack)
	doubled = true
	stack.z_index = 1
	stack.generateStack(wager)
	add_child(stack)
	stack.set_global_position(BET_START) 
	var	tween = create_tween()
	tween.tween_property(stack, "position", get_node("ChipStack").position + Vector2(32, -5), 0.2)

func	payoutStack(is_blackjack: bool):
	if doubled:
		var extra_pay = chip_stack_scene.instantiate()
		extra_stacks.append(extra_pay)
		extra_pay.generateStack(wager)
		add_child(extra_pay)
		extra_pay.set_global_position(Vector2(400, 100))
		create_tween().tween_property(extra_pay, "position", extra_stacks[0].position + Vector2(0, -28), 0.2)
	var	stack = chip_stack_scene.instantiate()
	extra_stacks.append(stack)
	# stack.position = 
	stack.generateStack(wager * (2 + int(is_blackjack)) / 2)
	add_child(stack)
	stack.set_global_position(Vector2(400, 100))
	await create_tween().tween_property(stack, "position", get_node("ChipStack").position + Vector2(0, -28), 0.2)

func	loseStack():
	var	main_stack = get_node("ChipStack")
	var tween: Tween = create_tween()

	if doubled:
		var tween2: Tween = create_tween()
		tween2.tween_property(extra_stacks[0], "global_position", Vector2(400, 100), 0.2)
	tween.tween_property(main_stack, "global_position", Vector2(400, 100), 0.2)
	await tween.finished
	if doubled:
		extra_stacks[0].reset()
		extra_stacks[0].queue_free()
		extra_stacks.clear()
	main_stack.reset()

func _ready() -> void:
	pass # Replace with function body.
