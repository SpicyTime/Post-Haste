extends "res://StateMachine/state.gd"
func can_enter() -> bool:
	return machine_owner.velocity.y < 0 or machine_owner.jump_pressed
	
func update(delta: float) -> void:
	machine_owner.apply_horizontal_movement(delta)
	machine_owner.velocity.y += machine_owner.GRAVITY * delta
