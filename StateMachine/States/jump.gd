extends "res://StateMachine/state.gd"
func can_enter() -> bool:
	return player.velocity.y < 0 or player.jump_pressed
	
func update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.velocity.y += player.GRAVITY * delta
