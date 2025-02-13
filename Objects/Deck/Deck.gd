extends Node

const	VALUES = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"]
const	PENETRATION = 0.8
const	DECK_COUNT = 4

const	card_path = preload("res://Objects/Card/Card.tscn")

var	cards = []

func	shuffle():
	print("Shuffling")
	for value in VALUES:
		for suit in range(4):
			for i in range(DECK_COUNT):
				var	card = card_path.instantiate()
				card.setValue(value, suit)
				cards.append(card)
	cards.shuffle()

func drawCard():
	return cards.pop_back()

func _ready() -> void:
	pass
