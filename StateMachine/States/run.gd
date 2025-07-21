extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return machine_owner.input_vector.x != 0 and machine_owner.is_on_floor() and not machine_owner.is_sliding
	
func update(delta: float) -> void:
	machine_owner.velocity.x = move_toward( machine_owner.velocity.x,  machine_owner.input_vector.x *  machine_owner.MAX_WALK_SPEED,  machine_owner.ACCEL * delta)
	machine_owner.velocity.y += machine_owner.GRAVITY * delta
