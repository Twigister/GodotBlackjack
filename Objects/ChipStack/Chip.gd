extends Sprite2D

const	TEXTURE_WIDTH = 32
const	TEXTURE_HEIGHT = 48
const	TEXTURE_GAP = 192
const	VALUES = [5, 10, 1, 500, 25, 5000, 100, 1000]

func	setValue(value: int):
	var	valueOffset
	for	i in range(len(VALUES)):
		if value == VALUES[i]:
			valueOffset =  i
			break
	region_rect = Rect2((valueOffset % 2) * TEXTURE_GAP, (valueOffset / 2) * TEXTURE_HEIGHT, TEXTURE_WIDTH, TEXTURE_HEIGHT)
