extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	var can_idle_from_input: bool = not player.jump_pressed and not player.is_sliding and  ( player.input_vector.x == 0 and not player.is_crouching )
	
	return player.is_on_floor() and can_idle_from_input and not player.is_touching_ceiling()

func update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0 , player.FRICTION * delta )
