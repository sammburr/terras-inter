class_name UISprintCharges
extends Control

@export var color_rects : Array[ColorRect]

var charges_left : int

func _ready() -> void:
	charges_left = color_rects.size()

func _use_charge() -> void:
	if charges_left > 0:
		charges_left -= 1
		color_rects[charges_left].hide()

func _recharge() -> void:
	if charges_left < color_rects.size():
		charges_left += 1
		color_rects[charges_left-1].show()

func try_use_charge() -> bool:
	if charges_left > 0:
		_use_charge()
		return true
	else:
		return false

func try_recharge() -> bool:
	if charges_left < color_rects.size():
		_recharge()
		return true
	else:
		return false
