extends Node

var	game_status = GameState.BETTING
signal	status_changed(new_status)

enum GameState	{
	WAITING_PLAYER_ACTION,
	DEALER_TURN,
	ROUND_END,
	BETTING,
	DEALING_CARD,
	CARD_DEALT,
	DEALING_HAND
}

func	changeGameStatus(status: GameState) -> void:
	game_status = status
	emit_signal("status_changed", game_status)

func	waitStatus(status: GameState) -> void:
	while game_status != status:
		await status_changed
