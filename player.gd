extends CharacterBody2D
class_name Player
@onready var left_wall_check: RayCast2D = $RayChecks/LeftWallCheck
@onready var right_wall_check: RayCast2D = $RayChecks/RightWallCheck
@onready var ceiling_check: RayCast2D = $RayChecks/CeilingCheck
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_machine: Node = $StateMachine
@onready var label: Label = $Label
@onready var coyote_timer: Timer = $CoyoteTimer

@export var coyote_time_buffer: float = 0.2

const GRAVITY: int = 1200
const MAX_WALK_SPEED: int = 200
const MAX_CROUCH_SPEED: int = 125
const ACCEL: int = 1000
const SLIDE_FORCE: int = 225
const JUMP_FORCE: int = 340
const SLIDE_JUMP_BOOST: int = 30
const FRICTION: int = 1400
const SLIDE_FRICTION: int = 300
const AIR_FRICTION: int = 600
var state_textures: Dictionary = {}
var state_colliders: Dictionary = {}
var is_sliding: bool = false
var is_crouching: bool = false
var jump_pressed: bool = false
var slide_pressed: bool = false
var crouch_pressed: bool = false
var can_coyote: bool = false
var can_jump: bool = false
var input_vector: Vector2 = Vector2.ZERO
var jump_chain_time: float = 0.7
var time_since_wall_jump: float = 0.0

func disable_colliders() -> void:
	$RegCollider.disabled = true
	$SlideCollider.disabled = true
	$CrouchCollider.disabled = true
#Returns true only if the input direction is the same as the current wall that the player is touching and if they are not on the floor
func check_wall_slide_manual() -> bool:
	return (
		(input_vector.x > 0 and _is_on_right_wall()) or 
		(input_vector.x < 0 and _is_on_left_wall())
	) and not is_on_floor()
	
func is_touching_wall_only() -> bool:
	return (_is_on_right_wall() or _is_on_left_wall()) and not is_on_floor()

func _is_on_left_wall() -> bool:
	return left_wall_check.is_colliding()  
	
func _is_on_right_wall() -> bool:
	return right_wall_check.is_colliding()
	
func get_ray_collision_object(ray: RayCast2D) -> Node2D:
	if ray:
		if ray.is_colliding():
			return ray.get_collider()
	return null
	
func get_ray_collision_point(ray: RayCast2D) -> Vector2:
	if ray:
		if ray.is_colliding():
			return ray.get_collision_point()
	return Vector2.ZERO
	
func is_touching_ceiling()-> bool: 
	return ceiling_check.is_colliding()

func perform_wall_jump() -> void:
	#Checks which wall the player is sliding on and applies a diagnol force in the opposite direction
	if _is_on_left_wall():
		velocity.x = JUMP_FORCE * 0.75 
	else:
		velocity.x = -JUMP_FORCE * 0.75 
	velocity.y = -JUMP_FORCE *  0.75
	time_since_wall_jump = 0.0
	
func _should_perform_slide() -> bool:
	if  input_vector.x != 0 and is_crouching :
		if state_machine.get_state_name(state_machine.prev_state) == "fall":
			return true
		elif state_machine.get_state_name(state_machine.prev_state) !=" fall" and crouch_pressed:
			return true
	return false
	
func get_facing_direction() -> int:
	if sprite_2d.flip_h == false:
		return 1
	return -1

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
		
	set_collision_mask_value(2, true)
	is_crouching = false
	if Input.is_action_pressed("crouch"):
		set_collision_mask_value(2, false)
		is_crouching = true
		 
	crouch_pressed = Input.is_action_just_pressed("crouch")
	
	#Checks if certain actions are being pressed
	slide_pressed = _should_perform_slide()
	jump_pressed = Input.is_action_just_pressed("jump")
	if jump_pressed and (is_on_floor()  or can_coyote) :
		if state_machine.get_state_name(state_machine.prev_state) == "slide":
			is_sliding = false
			velocity.y = -JUMP_FORCE + -SLIDE_JUMP_BOOST
		else:
			velocity.y = -JUMP_FORCE
	
func apply_horizontal_movement(delta: float) -> void:
	if input_vector != Vector2.ZERO:
		velocity.x = move_toward(velocity.x, input_vector.x * MAX_CROUCH_SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func _physics_process(delta: float) -> void:
	_handle_input()
	state_machine.update(delta)
	$Label.text = state_machine.current_state_name
	move_and_slide()

func _process(delta: float) -> void:
	time_since_wall_jump += delta
	coyote_timer.wait_time = coyote_time_buffer
	#Flips sprite based on movement direction
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
	
func _on_coyote_timer_timeout() -> void:
	can_coyote = false
