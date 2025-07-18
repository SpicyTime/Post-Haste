extends CharacterBody2D
@onready var left_wall_check: RayCast2D = $LeftWallCheck
@onready var right_wall_check: RayCast2D = $RightWallCheck
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var coyote_timer: Timer = $CoyoteTimer

@export var coyote_time_buffer: float = 0.2

enum PlayerState{
	IDLE,
	RUN,
	JUMP,
	WALL_SLIDE,
	SLIDE,
	FALL,
	CROUCH
}

const GRAVITY: int = 1200
const MAX_WALK_SPEED: int = 200
const MAX_CROUCH_SPEED: int = 125
const ACCEL: int = 1000
const JUMP_FORCE: int = 325
const SLIDE_FORCE: int = 225
const FRICTION: int = 1400
const SLIDE_FRICTION: int = 300
var state: PlayerState = PlayerState.IDLE
var state_textures: Dictionary = {}
var state_colliders: Dictionary = {}
var is_sliding: bool = false
var jump_pressed: bool = false
var slide_pressed: bool = false
var crouch_pressed: bool = false
var dash_pressed: bool = false
var can_coyote: bool = false
var input_vector: Vector2 = Vector2.ZERO
var prev_texture: Texture2D
var prev_state: PlayerState = PlayerState.IDLE
var jump_chain_time: float = 0.7
var time_since_wall_jump: float = 0.0

func _is_on_left_wall() -> bool:
	return left_wall_check.is_colliding()  
	
func _is_on_right_wall() -> bool:
	return right_wall_check.is_colliding()
	
func _perform_wall_jump() -> void:
	#Checks which wall the player is sliding on and applies a diagnol force in the opposite direction
	if _is_on_left_wall():
		velocity.x = JUMP_FORCE * 0.75 
	else:
		velocity.x = -JUMP_FORCE * 0.75 
	velocity.y = -JUMP_FORCE *  0.75
	time_since_wall_jump = 0.0
	
func _process(delta: float) -> void:
	time_since_wall_jump += delta
	coyote_timer.wait_time = coyote_time_buffer
	#Flips sprite based on movement direction
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
		
func _physics_process(delta: float) -> void:
	_handle_input()
	match state:
		PlayerState.IDLE:
			_process_idle(delta)
		PlayerState.RUN:
			_process_run(delta)
		PlayerState.JUMP:
			_process_jump(delta)
		PlayerState.WALL_SLIDE:
			_process_wall_slide(delta)
		PlayerState.SLIDE:
			_process_slide(delta)
		PlayerState.FALL:
			_process_fall(delta)
		#PlayerState.CROUCH:
			#_process_crouch(delta)
	_update_state()
	move_and_slide()
	
func _ready() -> void:
	#Initializes the dictionary responsible for swapping textures based on the current PlayerState
	state_textures[PlayerState.IDLE] = preload("res://Assets/Sprites/Player/PlayerIdle.png")
	state_textures[PlayerState.SLIDE] = preload("res://Assets/Sprites/Player/PlayerSliding.png")
	state_textures[PlayerState.CROUCH] = preload("res://Assets/Sprites/Player/PlayerCrouching.png")
	state_textures[PlayerState.FALL] = preload("res://Assets/Sprites/Player/PlayerFalling.png")
	state_textures[PlayerState.JUMP] = preload("res://Assets/Sprites/Player/PlayerJumping.png")
	state_textures[PlayerState.RUN] = preload("res://Assets/Sprites/Player/PlayerRun.png")
	state_textures[PlayerState.WALL_SLIDE] = preload("res://Assets/Sprites/Player/PlayerWallSliding.png")
	

func _handle_input() -> void:
	var fall_accel: int = 10
	#Gets the input direction
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x = 1
	elif Input.is_action_pressed("move_left"):
		input_vector.x = -1
	if Input.is_key_pressed(KEY_S):
		velocity.y += fall_accel
	#Checks if certain actions are being pressed
	crouch_pressed = Input.is_action_just_pressed("crouch")
	slide_pressed = input_vector.x != 0  and crouch_pressed
	jump_pressed = Input.is_action_just_pressed("jump")
	
	if jump_pressed and (is_on_floor()  or can_coyote):
		if prev_state == PlayerState.SLIDE:
			is_sliding = false
			velocity.y = -JUMP_FORCE + -20
		else:
			velocity.y = -JUMP_FORCE
		
	if slide_pressed and is_on_floor() and not is_sliding:
		velocity.x += input_vector.x * SLIDE_FORCE
		is_sliding = true
		
	#Checks if the player's input direction is not the current direction of the velocity while sliding
	#If true the slide is cancelled and the player is slowed down and put in the RUN state
	if is_sliding and ((input_vector.x < 0 and velocity.x > 0) or (input_vector.x > 0 and velocity.x < 0)):
		is_sliding = false
		velocity.x /= 1.5
	elif _is_touching_wall_only():
		if jump_pressed and (state == PlayerState.WALL_SLIDE or time_since_wall_jump <= jump_chain_time):
			_perform_wall_jump()
		
func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += GRAVITY * delta
	
func _process_run(delta: float) -> void:
	velocity.x = move_toward(velocity.x, input_vector.x * MAX_WALK_SPEED, ACCEL * delta)
	velocity.y += GRAVITY * delta
	
func _process_jump(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
func _process_fall(delta: float) -> void:
	velocity.y += GRAVITY * delta
	# Allow movement while falling
	if input_vector != Vector2.ZERO:
		velocity.x = move_toward(velocity.x, input_vector.x * MAX_WALK_SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func _process_slide(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, SLIDE_FRICTION * delta)
	velocity.y += GRAVITY * delta
	
func _process_wall_slide(delta: float) -> void:
	velocity.y = min(velocity.y + GRAVITY * delta, 30)
	
#func _process_crouch(delta: float) -> void:
	#velocity.x = move_toward(velocity.x, input_vector.x * MAX_CROUCH_SPEED, ACCEL * delta)
#This is used for displaying the state above the players head
func get_state_name(player_state: PlayerState) -> String:
	match player_state:
		PlayerState.IDLE: return "IDLE"
		PlayerState.RUN: return "RUN"
		PlayerState.JUMP: return "JUMP"
		PlayerState.WALL_SLIDE: return "WALL_SLIDE"
		PlayerState.SLIDE: return "SLIDE"
		PlayerState.FALL: return "FALL"
		PlayerState.CROUCH: return "CROUCH"
	return "UNKNOWN"
#Changes the collider size based on the current state
func _swap_collider(player_state: PlayerState) -> void:
	$RegCollider.disabled = true
	$SlideCollider.disabled = true
	if player_state == PlayerState.SLIDE:
		$SlideCollider.disabled = false
		global_position.y += 8
	else:
		$RegCollider.disabled = false
#Returns true only if the input direction is the same as the current wall that the player is touching and if they are not on the floor
func _check_wall_slide_manual() -> bool:
	return (
		(input_vector.x > 0 and _is_on_right_wall()) or 
		(input_vector.x < 0 and _is_on_left_wall())
	) and not is_on_floor()
	
func _is_touching_wall_only() -> bool:
	return (_is_on_right_wall() or _is_on_left_wall()) and not is_on_floor()
	
func _update_state() -> void:
	prev_state = state
	#Handles all the basic floor states
	if is_on_floor() and not is_sliding:
		if input_vector.x == 0 :
			state = PlayerState.IDLE
		else:
			state = PlayerState.RUN
	#Handles the sliding state
	elif is_on_floor() and is_sliding:
		state = PlayerState.SLIDE
		#Another way the slide is cancelled.
		#If the player is not inputting a horizontal movement direction and the player is going too slow
		#the slide is cancelled and the player is put in the IDLE state.
		if input_vector.x == 0 and abs(velocity.x) < 1:
			state = PlayerState.IDLE
			is_sliding = false
		#Otherwise, if the player is inputting a movement direction and the player is going too slow
		#the slide will be cancelled and the player will be put in the RUN state.
		elif input_vector.x != 0 and abs(velocity.x) < MAX_WALK_SPEED:
			state = PlayerState.RUN
			is_sliding = false
	elif _check_wall_slide_manual() or ( _is_touching_wall_only() and time_since_wall_jump <= jump_chain_time):
		state = PlayerState.WALL_SLIDE
	elif velocity.y < 0 or jump_pressed:
		state = PlayerState.JUMP
	else:
		state = PlayerState.FALL
		if prev_state != PlayerState.JUMP and prev_state != PlayerState.FALL and prev_state != PlayerState.WALL_SLIDE:
			coyote_timer.start()
			can_coyote = true
	#Swaps textures and colliders based on the current PlayerState
	if prev_texture != state_textures.get(state):
		label.text = get_state_name(state)
		if state in state_textures.keys():
			sprite_2d.texture = state_textures.get(state)
			prev_texture = state_textures.get(state)
			_swap_collider(state)

func _on_coyote_timer_timeout() -> void:
	can_coyote = false
