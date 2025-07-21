extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return machine_owner.check_wall_slide_manual() or ( machine_owner.is_touching_wall_only() and machine_owner.time_since_wall_jump <= machine_owner.jump_chain_time)
	
func update(delta: float) -> void:
	machine_owner.velocity.y = min(machine_owner.velocity.y + machine_owner.GRAVITY * delta, 30)
