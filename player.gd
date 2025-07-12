extends CharacterBody2D
@onready var left_wall_check: RayCast2D = $LeftWallCheck
@onready var right_wall_check: RayCast2D = $RightWallCheck
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label


var state_textures: Dictionary = {}
var state_colliders: Dictionary = {}
enum PlayerState{
	IDLE,
	RUN,
	JUMP,
	WALL_SLIDE,
	SLIDE,
	FALL,
	CROUCH
}
var state: PlayerState = PlayerState.IDLE
const GRAVITY: int = 1200
const MAX_WALK_SPEED: int = 200
const ACCEL: int = 1000
const JUMP_FORCE: int = 325
const SLIDE_FORCE: int = 225
const FRICTION: int = 1600
const SLIDE_FRICTION: int = 300
var is_wall_sliding: bool = false
var is_sliding: bool = false
var wall_jumped: bool = false
var jump_pressed: bool = false
var slide_pressed: bool = false
var crouch_pressed: bool = false
var dash_pressed: bool = false
var input_vector: Vector2 = Vector2.ZERO
var prev_texture: Texture2D
func _is_on_left_wall() -> bool:
	return left_wall_check.is_colliding()
	
func _is_on_right_wall() -> bool:
	return right_wall_check.is_colliding()
	
func _perform_wall_jump() -> void:
	if _is_on_left_wall():
		velocity.x = JUMP_FORCE * 0.75 
	else:
		velocity.x = -JUMP_FORCE * 0.75 
	velocity.y = -JUMP_FORCE *  0.75
	wall_jumped = true

func _physics_process(delta: float) -> void:
	wall_jumped = false
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
	
	
	_update_state()
	move_and_slide()
func _ready() -> void:
	state_textures[PlayerState.IDLE] = preload("res://Assets/Sprites/Player/PlayerIdle.png")
	state_textures[PlayerState.SLIDE] = preload("res://Assets/Sprites/Player/PlayerSliding.png")
	state_textures[PlayerState.CROUCH] = preload("res://Assets/Sprites/Player/PlayerCrouching.png")
	state_textures[PlayerState.FALL] = preload("res://Assets/Sprites/Player/PlayerFalling.png")
	state_textures[PlayerState.JUMP] = preload("res://Assets/Sprites/Player/PlayerJumping.png")
	state_textures[PlayerState.RUN] = preload("res://Assets/Sprites/Player/PlayerRun.png")
	state_textures[PlayerState.WALL_SLIDE] = preload("res://Assets/Sprites/Player/PlayerWallSliding.png")
	var crouch_collider_shape: CapsuleShape2D = CapsuleShape2D.new()
	crouch_collider_shape.height = 20
	crouch_collider_shape.radius = 7
	state_colliders[PlayerState.CROUCH] = crouch_collider_shape

func _handle_input() -> void:
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x = 1
	elif Input.is_action_pressed("move_left"):
		input_vector.x = -1
	dash_pressed = Input.is_action_just_pressed("dash")
	crouch_pressed = Input.is_action_pressed("crouch")
	#print(dash_pressed, input_vector.x != 0, crouch_pressed)
	 
	slide_pressed = input_vector.x != 0 and dash_pressed and crouch_pressed
	jump_pressed = Input.is_action_just_pressed("jump")
	if slide_pressed and is_on_floor():
		state = PlayerState.SLIDE
		velocity.x += input_vector.x * SLIDE_FORCE
		is_sliding = true
		
	if jump_pressed and is_on_floor():
		velocity.y += -JUMP_FORCE
		state = PlayerState.JUMP
		
	elif jump_pressed and is_on_wall():
		_perform_wall_jump()
		state = PlayerState.JUMP
		
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
	
func get_state_name(state: PlayerState) -> String:
	match state:
		PlayerState.IDLE: return "IDLE"
		PlayerState.RUN: return "RUN"
		PlayerState.JUMP: return "JUMP"
		PlayerState.WALL_SLIDE: return "WALL_SLIDE"
		PlayerState.SLIDE: return "SLIDE"
		PlayerState.FALL: return "FALL"
		PlayerState.CROUCH: return "CROUCH"
	return "UNKNOWN"
func _swap_collider(player_state: PlayerState) -> void:
	$RegCollider.disabled = true
	$CrouchCollider.disabled = true
	$SlideCollider.disabled = true
	if player_state == PlayerState.CROUCH:
		$CrouchCollider.disabled = false
		global_position.y += 8
	elif player_state == PlayerState.SLIDE:
		$SlideCollider.disabled = false
		global_position.y += 8
	else:
		$RegCollider.disabled = false
	
func _update_state() -> void:
	if is_on_floor() and not is_sliding:
		if input_vector.x == 0 and not crouch_pressed:
			state = PlayerState.IDLE
		elif input_vector.x == 0 and crouch_pressed:
			state = PlayerState.CROUCH
		else:
			state = PlayerState.RUN
			
	elif is_on_floor() and is_sliding:
		state = PlayerState.SLIDE
		if input_vector.x == 0 and abs(velocity.x) < 1:
			state = PlayerState.IDLE
			is_sliding = false
			
		elif input_vector.x != 0 and abs(velocity.x) < MAX_WALK_SPEED:
			state = PlayerState.RUN
			is_sliding = false
			
	elif is_on_wall() and input_vector.x != 0 and not is_on_floor():
		state = PlayerState.WALL_SLIDE
	elif slide_pressed:
		state = PlayerState.SLIDE
	elif velocity.y < 0:
		state = PlayerState.JUMP
	else:
		state = PlayerState.FALL
	if prev_texture != state_textures.get(state):
		
		label.text = get_state_name(state)
		if state in state_textures.keys():
			sprite_2d.texture = state_textures.get(state)
			prev_texture = state_textures.get(state)
			_swap_collider(state)
