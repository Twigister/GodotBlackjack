extends Node2D

var	chip_scene = preload("res://Objects/ChipStack/Chip.tscn")
const	VALUES = [5000, 1000, 500, 100, 25, 10, 5, 1]

var	chips = []
var	chip_count = 0

func	reset() -> void:
	for chip in chips:
		chip.queue_free()
	chip_count = 0

func generateStack(value: int):
	var chip_position = Vector2(0, 0)
	while value:
		for denom in VALUES:
			if denom <= value:
				var chip = chip_scene.instantiate()
				chips.append(chip)
				chip.setValue(denom)
				chip.position = chip_position
				value -= denom
				chip_count += 1
				break
		chip_position += Vector2(0, 5)
	for i in range(len(chips)):
		add_child(chips[len(chips) - i - 1])

func	clear() -> void:
	for chip in chips:
		chip.queue_free()
	chips.clear()
