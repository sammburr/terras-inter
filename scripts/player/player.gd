class_name Player
extends Node3D

@export var player_model : PlayerModel

func _ready() -> void:
	player_model.walk()
