extends CharacterBody2D
@onready var left_wall_check: RayCast2D = $RayChecks/LeftWallCheck
@onready var right_wall_check: RayCast2D = $RayChecks/RightWallCheck
@onready var ceiling_check: RayCast2D = $RayChecks/CeilingCheck
@onready var climb_check_right: RayCast2D = $RayChecks/ClimbCheckRight
@onready var climb_check_left: RayCast2D = $RayChecks/ClimbCheckLeft
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
	CROUCH,
	HANG
}

const GRAVITY: int = 1200
const MAX_WALK_SPEED: int = 200
const MAX_CROUCH_SPEED: int = 125
const ACCEL: int = 1000
const SLIDE_FORCE: int = 225
const JUMP_FORCE: int = 325
const SLIDE_JUMP_BOOST: int = 30
const FRICTION: int = 1400
const SLIDE_FRICTION: int = 300
const AIR_FRICTION: int = 600
var state: PlayerState = PlayerState.IDLE
var state_textures: Dictionary = {}
var state_colliders: Dictionary = {}
var is_sliding: bool = false
var is_crouching: bool = false
var jump_pressed: bool = false
var slide_pressed: bool = false
var crouch_pressed: bool = false
var can_coyote: bool = false
var can_hang: bool = true
var input_vector: Vector2 = Vector2.ZERO
var prev_texture: Texture2D
var prev_state: PlayerState = PlayerState.IDLE
var jump_chain_time: float = 0.7
var time_since_wall_jump: float = 0.0

#Returns true only if the input direction is the same as the current wall that the player is touching and if they are not on the floor
func _check_wall_slide_manual() -> bool:
	return (
		(input_vector.x > 0 and _is_on_right_wall()) or 
		(input_vector.x < 0 and _is_on_left_wall())
	) and not is_on_floor()
func _hang_touching_wall() -> bool:
	return climb_check_left.is_colliding() or climb_check_right.is_colliding()
func _is_touching_wall_only() -> bool:
	return (_is_on_right_wall() or _is_on_left_wall()) and not is_on_floor()

func _is_on_left_wall() -> bool:
	return left_wall_check.is_colliding()  

func _is_touching_ceiling()-> bool: 
	return ceiling_check.is_colliding()
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
	
func _should_perform_slide() -> bool:
	if  input_vector.x != 0 and is_crouching :
		if prev_state == PlayerState.FALL:
			return true
		elif prev_state != PlayerState.FALL and crouch_pressed:
			return true
	return false
	
func _handle_input() -> void:
	var prev_input_vector: Vector2 = input_vector
	var fall_accel: int = 15
	#Gets the input direction
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x = 1
	elif Input.is_action_pressed("move_left"):
		input_vector.x = -1
		
	if prev_input_vector.x != input_vector.x and is_on_floor():
		velocity.x /= 1.75
		
	is_crouching = false
	if Input.is_action_pressed("crouch"):
		if state == PlayerState.FALL:
			velocity.y += fall_accel
		elif state == PlayerState.HANG:
			can_hang = false
			$HangCooldown.start()
		is_crouching = true
	crouch_pressed = Input.is_action_just_pressed("crouch")
	
	#Checks if certain actions are being pressed
	slide_pressed = _should_perform_slide()
	jump_pressed = Input.is_action_just_pressed("jump")
	
	if jump_pressed and (is_on_floor()  or can_coyote):
		if prev_state == PlayerState.SLIDE:
			is_sliding = false
			velocity.y = -JUMP_FORCE + -SLIDE_JUMP_BOOST
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

func _update_state() -> void:
	prev_state = state
	#Handles all the basic floor states
	if is_on_floor() and not is_sliding:
		if input_vector.x == 0 and not is_crouching :
				state = PlayerState.IDLE
		else:
			state = PlayerState.RUN
		if is_crouching or ((prev_state == PlayerState.SLIDE or prev_state == PlayerState.CROUCH) and _is_touching_ceiling()):
			state = PlayerState.CROUCH
	#Handles the sliding state
	elif is_on_floor() and is_sliding:
		state = PlayerState.SLIDE
		#Another way the slide is cancelled.
		#If the player is not inputting a horizontal movement direction and the player is going too slow
		#the slide is cancelled and the player is put in the IDLE state.
		if input_vector.x == 0 and abs(velocity.x) < 1 and not is_crouching:
			if _is_touching_ceiling():
				state = PlayerState.CROUCH
			else:
				state = PlayerState.IDLE
			is_sliding = false
		#Otherwise, if the player is inputting a movement direction and the player is going too slow
		#the slide will be cancelled and the player will be put in the RUN state.
		elif input_vector.x != 0 and abs(velocity.x) < MAX_WALK_SPEED and not is_crouching:
			if _is_touching_ceiling():
				state = PlayerState.CROUCH
			else:
				state = PlayerState.RUN
			is_sliding = false
	elif _check_wall_slide_manual() or ( _is_touching_wall_only() and time_since_wall_jump <= jump_chain_time):
		state = PlayerState.WALL_SLIDE
	elif _is_touching_wall_only() and  not _hang_touching_wall() and can_hang:
		state = PlayerState.HANG
	elif velocity.y < 0 or jump_pressed:
		state = PlayerState.JUMP
	else:
		state = PlayerState.FALL
		if prev_state != PlayerState.JUMP and prev_state != PlayerState.FALL and prev_state != PlayerState.WALL_SLIDE:
			coyote_timer.start()
			can_coyote = true
	#Swaps textures and colliders based on the current PlayerState
	if prev_texture != state_textures.get(state):
		label.text = _get_state_name(state)
		if state in state_textures.keys():
			sprite_2d.texture = state_textures.get(state)
			prev_texture = state_textures.get(state)
			_swap_collider(state)

func _swap_collider(player_state: PlayerState) -> void:
	#Changes the collider size based on the current state
	$RegCollider.disabled = true
	$SlideCollider.disabled = true
	$CrouchCollider.disabled = true
	if player_state == PlayerState.SLIDE:
		$SlideCollider.disabled = false
		if prev_state != PlayerState.CROUCH:
			global_position.y += 8
	elif player_state == PlayerState.CROUCH:
		$CrouchCollider.disabled = false
		if prev_state != PlayerState.SLIDE:
			global_position.y += 10
	else:
		$RegCollider.disabled = false

func _get_state_name(player_state: PlayerState) -> String:
	#This is used for displaying the state above the players head
	match player_state:
		PlayerState.IDLE: return "IDLE"
		PlayerState.RUN: return "RUN"
		PlayerState.JUMP: return "JUMP"
		PlayerState.WALL_SLIDE: return "WALL_SLIDE"
		PlayerState.SLIDE: return "SLIDE"
		PlayerState.FALL: return "FALL"
		PlayerState.CROUCH: return "CROUCH"
		PlayerState.HANG: return "HANG"
	return "UNKNOWN"
	
func _apply_horizontal_movement(delta: float) -> void:
	if input_vector != Vector2.ZERO:
		velocity.x = move_toward(velocity.x, input_vector.x * MAX_CROUCH_SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += GRAVITY * delta

func _process_run(delta: float) -> void:
	velocity.x = move_toward(velocity.x, input_vector.x * MAX_WALK_SPEED, ACCEL * delta)
	velocity.y += GRAVITY * delta

func _process_jump(delta: float) -> void:
	_apply_horizontal_movement(delta)
	velocity.y += GRAVITY * delta

func _process_fall(delta: float) -> void:
	velocity.y += GRAVITY * delta
	# Allow movement while falling
	_apply_horizontal_movement(delta)

func _process_slide(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, SLIDE_FRICTION * delta)
	velocity.y += GRAVITY * delta

func _process_wall_slide(delta: float) -> void:
	velocity.y = min(velocity.y + GRAVITY * delta, 30)

func _process_crouch(delta: float) -> void:
	_apply_horizontal_movement(delta)
	
func _process_hang(_delta: float) -> void:
	var hand_offset: Vector2 = Vector2(7, -7)
	var hand_pos: Vector2 = global_position + hand_offset
	
	var y: int = int(hand_pos.y)
	var snapped_y = y - ((y ) % 16)
	if abs(snapped_y + 16 - y) < abs(snapped_y - y):
		snapped_y += 16

	var delta_y: int= snapped_y - int(hand_pos.y)
	global_position.y += delta_y

	
	velocity = Vector2.ZERO
	
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
		PlayerState.CROUCH:
			_process_crouch(delta)
		PlayerState.HANG:
			_process_hang(delta)
	_update_state()
	move_and_slide()

func _process(delta: float) -> void:
	time_since_wall_jump += delta
	coyote_timer.wait_time = coyote_time_buffer
	#Flips sprite based on movement direction
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true

func _ready() -> void:
	#Initializes the dictionary responsible for swapping textures based on the current PlayerState
	state_textures[PlayerState.IDLE] = preload("res://Assets/Sprites/Player/PlayerIdle.png")
	state_textures[PlayerState.SLIDE] = preload("res://Assets/Sprites/Player/PlayerSliding.png")
	state_textures[PlayerState.CROUCH] = preload("res://Assets/Sprites/Player/PlayerCrouching.png")
	state_textures[PlayerState.FALL] = preload("res://Assets/Sprites/Player/PlayerFalling.png")
	state_textures[PlayerState.JUMP] = preload("res://Assets/Sprites/Player/PlayerJumping.png")
	state_textures[PlayerState.RUN] = preload("res://Assets/Sprites/Player/PlayerRun.png")
	state_textures[PlayerState.WALL_SLIDE] = preload("res://Assets/Sprites/Player/PlayerWallSliding.png")
	state_textures[PlayerState.HANG] = preload("res://Assets/Sprites/Player/PlayerHang.png")
func _on_coyote_timer_timeout() -> void:
	can_coyote = false


func _on_hang_cooldown_timeout() -> void:
	can_hang = true
