extends Sprite2D

const	CARD_HEIGHT = 64
const 	CARD_WIDTH = 48

const	VALUES = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"]
var		valueNo

func	setValue(value: String, suit :int):
	for i in range(13):
		if value == VALUES[i]:
			valueNo = i
	region_rect = Rect2(CARD_WIDTH * valueNo, CARD_HEIGHT * suit, CARD_WIDTH, CARD_HEIGHT)

# Specialized getters
func	getValue() -> int:
	if valueNo >= 9:
		return 10
	return valueNo + 1
