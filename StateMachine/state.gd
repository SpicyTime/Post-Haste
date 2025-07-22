extends Node
class_name State
var player: Player = null
var state_machine: StateMachine = null

func can_enter() -> bool:
	return false
	
func enter() -> void:
	pass
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
