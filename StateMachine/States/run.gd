extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	var can_run_from_input: bool = not player.is_sliding and not  player.jump_pressed and player.input_vector.x != 0
	return player.is_on_floor() and can_run_from_input and not player.is_touching_ceiling()
	
func update(delta: float) -> void:
	player.velocity.x = move_toward( player.velocity.x,  player.input_vector.x *  player.MAX_WALK_SPEED,  player.ACCEL * delta)
	player.velocity.y += player.GRAVITY * delta
	
