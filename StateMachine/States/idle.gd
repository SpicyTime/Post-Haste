extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return machine_owner.is_on_floor() and not machine_owner.is_sliding and  (
		machine_owner.input_vector.x == 0 and not machine_owner.is_crouching )

func update(delta: float) -> void:
	machine_owner.velocity.x = move_toward(machine_owner.velocity.x, 0 , machine_owner.FRICTION * delta )
