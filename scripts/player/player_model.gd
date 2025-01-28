class_name PlayerModel
extends Node3D

@export var animation_player : AnimationPlayer

func idle():
	animation_player.play("Idle")

func walk():
	animation_player.play("Walk")
	
