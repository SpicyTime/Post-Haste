extends "res://StateMachine/state.gd"
var is_snapped: bool = false
func _snap_to_edge() -> void:
	var hand_offset: Vector2 = Vector2(7, -7)
	var hand_pos: Vector2 = player.global_position + hand_offset
	var y: int = int(hand_pos.y)
	var snapped_y: int = y - ((y ) % 16)
	if abs(snapped_y + 16 - y) < abs(snapped_y - y):
		snapped_y += 16
	var delta_y: int= snapped_y - int(hand_pos.y)
	player.global_position.y += delta_y
	is_snapped = true
	
func can_enter() -> bool:
	return player.should_hang() and player.can_hang
	
func exit() -> void:
	is_snapped = false
	
func update(delta: float) -> void:
	if not is_snapped: 
		_snap_to_edge()
	if player.should_cancel_hang():
		player.can_hang = false
		player.hang_cooldown.start()
	player.velocity = Vector2.ZERO
