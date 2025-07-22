extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return true

func enter() -> void:
	pass
	
func update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	var fall_accel: float = 1
	if player.is_crouching:
		fall_accel = 1.5
	player.velocity.y += player.GRAVITY * delta * fall_accel
	
