extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return player.is_on_floor() and not player.is_sliding and  (
		player.input_vector.x == 0 and not player.is_crouching ) and not player.is_touching_ceiling()
func enter() -> void:
	print("entered idle")
func update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0 , player.FRICTION * delta )
