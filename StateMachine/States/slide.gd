extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	var can_slide_from_input: bool = (player.is_sliding or (player.slide_pressed and not player.is_sliding)) and not player.jump_pressed
	return player.is_on_floor() and can_slide_from_input
	
func enter() -> void:
	player.velocity.x += player.input_vector.x * player.SLIDE_FORCE
	player.is_sliding = true
	
func update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.SLIDE_FRICTION * delta)
	player.velocity.y += player.GRAVITY * delta
	
	#Checks if the player's input direction is not the current direction of the velocity while sliding
	#If true the slide is cancelled and the player is slowed down and put in the RUN state
	if player.is_sliding and ((player.input_vector.x < 0 and player.velocity.x > 0) or (player.input_vector.x > 0 and player.velocity.x < 0)):
		player.is_sliding = false
		player.velocity.x /= 1.5
	#Another way the slide is cancelled.
		#If the player is not inputting a horizontal movement direction and the player is going too slow
		#the slide is cancelled and the player is put in the IDLE state.
	if player.input_vector.x == 0 and abs(player.velocity.x) < 1 and not player.is_crouching:
		player.is_sliding = false
		
	
		#Otherwise, if the player is inputting a movement direction and the player is going too slow
		#the slide will be cancelled and the player will be put in the RUN state.
	elif player.input_vector.x != 0 and abs(player.velocity.x) < player.MAX_WALK_SPEED / 2 and not player.is_crouching:
		player.is_sliding = false
		
