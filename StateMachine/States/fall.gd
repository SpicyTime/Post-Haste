extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return true
	
func update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.velocity.y += player.GRAVITY * delta
