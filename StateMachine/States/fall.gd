extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return true
	
func update(delta: float) -> void:
	machine_owner.apply_horizontal_movement(delta)
	machine_owner.velocity.y += machine_owner.GRAVITY * delta
