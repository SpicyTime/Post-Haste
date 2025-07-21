extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	var prev_state_name = state_machine.get_state_name(state_machine.prev_state)
	return machine_owner.is_on_floor() and machine_owner.is_crouching or ((prev_state_name == "slide" or prev_state_name == "crouch") and machine_owner.is_touching_ceiling())
	
func update(delta: float) -> void:
	machine_owner.apply_horizontal_movement(delta)
