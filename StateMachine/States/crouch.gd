extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	
	return player.is_on_floor() and (player.is_crouching or player.is_touching_ceiling()) and not player.jump_pressed

func update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.is_crouching = true
