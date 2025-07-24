extends "res://StateMachine/state.gd"
func can_enter() -> bool:
	
	return (player.velocity.y < 0 or player.jump_pressed and (player.is_on_floor()  or player.can_coyote)  ) and not player.is_touching_ceiling()
	
func enter() -> void:
	if state_machine.get_state_name(state_machine.prev_state) == "slide":
		player.is_sliding = false
		player.velocity.y = -player.JUMP_FORCE + -player.SLIDE_JUMP_BOOST
	else:
		player.velocity.y = -player.JUMP_FORCE
		
func update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.velocity.y += player.GRAVITY * delta
