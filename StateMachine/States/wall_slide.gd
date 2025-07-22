extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return player.check_wall_slide_manual() or ( player.is_touching_wall_only() and player.time_since_wall_jump <= player.jump_chain_time)
	
func update(delta: float) -> void:
	player.velocity.y = min(player.velocity.y + player.GRAVITY * delta, 30)
