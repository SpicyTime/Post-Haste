extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return true

func enter() -> void:
	var prev_state_name = state_machine.get_state_name(state_machine.prev_state)
	player.can_coyote = prev_state_name != "jump" and prev_state_name != "fall" and prev_state_name != "wall_slide"
	player.coyote_timer.start() 
	
func update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	var fall_accel: float = 1
	if player.is_crouching:
		fall_accel = 1.5
	player.velocity.y += player.GRAVITY * delta * fall_accel
	
