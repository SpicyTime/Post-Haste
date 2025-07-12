extends Camera2D

@export var player: CharacterBody2D = null

# Bounds based on margins from center
var left_bound: float
var right_bound: float
var top_bound: float
var bottom_bound: float

const SPEED := 400.0

func _ready() -> void:
	var half_viewport = get_viewport_rect().size * 0.5

	# Margins from viewport center (not full size)
	var x_margin = 110
	var top_margin = 40
	var bottom_margin = 20

	left_bound = -(half_viewport.x - x_margin)
	right_bound = (half_viewport.x - x_margin)
	top_bound = -(half_viewport.y - top_margin)
	bottom_bound = (half_viewport.y - bottom_margin)
 
func _physics_process(delta: float) -> void:
	if player == null:
		return

	var player_offset: Vector2 = player.global_position - global_position
	var movement := Vector2.ZERO

	if player_offset.x < left_bound:
		movement.x = player_offset.x - left_bound
	elif player_offset.x > right_bound:
		movement.x = player_offset.x - right_bound

	if player_offset.y < top_bound:
		movement.y = player_offset.y - top_bound
	elif player_offset.y > bottom_bound:
		movement.y = player_offset.y - bottom_bound

	if movement != Vector2.ZERO:
		global_position += movement.normalized() * SPEED * delta
