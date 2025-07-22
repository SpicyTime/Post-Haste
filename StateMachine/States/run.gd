extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return player.input_vector.x != 0 and player.is_on_floor() and not player.is_sliding and not player.is_touching_ceiling()
	
func update(delta: float) -> void:
	player.velocity.x = move_toward( player.velocity.x,  player.input_vector.x *  player.MAX_WALK_SPEED,  player.ACCEL * delta)
	player.velocity.y += player.GRAVITY * delta
