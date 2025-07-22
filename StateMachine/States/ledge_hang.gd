extends "res://StateMachine/state.gd"
var is_snapped: bool = false
func _snap_to_edge() -> void:
	var hand_offset: Vector2 = Vector2(7, -7)
	var hand_pos: Vector2 = player.global_position + hand_offset
	var y: int = int(hand_pos.y)
	var snapped_y: int = y - ((y ) % 16) - 6
	if abs(snapped_y + 16 - y) < abs(snapped_y - y):
		snapped_y += 16
	var delta_y: int= snapped_y - int(hand_pos.y)
	player.global_position.y += delta_y  
	is_snapped = true
	
func _ray_colliding_with_ledge() -> bool:
	var ray: RayCast2D = player.floor_check
	
	var collision_point: Vector2 = player.get_ray_collision_point(ray)
	var collision_object: Node2D = player.get_ray_collision_object(ray)
	if collision_object is TileMapLayer:
		var snapped_point: Vector2 = collision_point.floor()
		if ray == player.left_wall_check:
			snapped_point.x -= 16
		var cell_coords: Vector2i = collision_object.local_to_map(snapped_point)
		print(cell_coords)
		var atlas_coords: Vector2 = collision_object.get_cell_atlas_coords(cell_coords)
		print(atlas_coords)
		if atlas_coords == Vector2(0, 1):
			return true
	return false
	
func can_enter() -> bool:
	print(_ray_colliding_with_ledge())
	return _ray_colliding_with_ledge() and player.can_hang
	
func exit() -> void:
	is_snapped = false
	
func update(delta: float) -> void:
	if not is_snapped:
		_snap_to_edge()
	if player.should_cancel_hang():
		player.can_hang = false
		player.hang_cooldown.start()
	player.velocity = Vector2.ZERO
