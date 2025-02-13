extends Node

func	playHand() -> void:
	while get_node("Hand").getScore() != -1 and get_node("Hand").getScore() < 17:
		await get_node("Hand").addCard(get_node("../Deck").drawCard())
	GameManager.changeGameStatus(GameManager.GameState.ROUND_END)
