extends "res://StateMachine/state.gd"

func can_enter() -> bool:
	return machine_owner.is_touching_wall_only() and  not machine_owner.hang_touching_wall() and machine_owner.can_hang
	
func update(delta: float) -> void:
	var hand_offset: Vector2 = Vector2(7, -7)
	var hand_pos: Vector2 = machine_owner.global_position + hand_offset
	var y: int = int(hand_pos.y)
	var snapped_y: int = y - ((y ) % 16)
	if abs(snapped_y + 16 - y) < abs(snapped_y - y):
		snapped_y += 16
	var delta_y: int= snapped_y - int(hand_pos.y)
	machine_owner.global_position.y += delta_y
	machine_owner.velocity = Vector2.ZERO
