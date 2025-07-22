extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return player.is_on_floor() and player.is_sliding
	
func update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.SLIDE_FRICTION * delta)
	player.velocity.y += player.GRAVITY * delta
	#Another way the slide is cancelled.
		#If the player is not inputting a horizontal movement direction and the player is going too slow
		#the slide is cancelled and the player is put in the IDLE state.
	if player.input_vector.x == 0 and abs(player.velocity.x) < 1 and not player.is_crouching:
		player.is_sliding = false
		
	
		#Otherwise, if the player is inputting a movement direction and the player is going too slow
		#the slide will be cancelled and the player will be put in the RUN state.
	elif player.input_vector.x != 0 and abs(player.velocity.x) < player.MAX_WALK_SPEED / 2 and not player.is_crouching:
		player.is_sliding = false
		
