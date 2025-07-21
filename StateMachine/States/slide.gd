extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return machine_owner.is_on_floor() and machine_owner.is_sliding
	
func update(delta: float) -> void:
	machine_owner.velocity.x = move_toward(machine_owner.velocity.x, 0, machine_owner.SLIDE_FRICTION * delta)
	machine_owner.velocity.y += machine_owner.GRAVITY * delta
	#Another way the slide is cancelled.
		#If the player is not inputting a horizontal movement direction and the player is going too slow
		#the slide is cancelled and the player is put in the IDLE state.
	if machine_owner.input_vector.x == 0 and abs(machine_owner.velocity.x) < 1 and not machine_owner.is_crouching:
		machine_owner.is_sliding = false
		#Otherwise, if the player is inputting a movement direction and the player is going too slow
		#the slide will be cancelled and the player will be put in the RUN state.
	elif machine_owner.input_vector.x != 0 and abs(machine_owner.velocity.x) < machine_owner.MAX_WALK_SPEED / 2 and not machine_owner.is_crouching:
		machine_owner.is_sliding = false
