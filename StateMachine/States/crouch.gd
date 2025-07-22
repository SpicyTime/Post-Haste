extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	var prev_state_name = state_machine.get_state_name(state_machine.prev_state)
	return player.is_on_floor() and (player.is_crouching or player.is_touching_ceiling())
func enter() -> void:
	print("Entered Crouch")
func update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.is_crouching = true
