extends Node
class_name StateMachine
@export var machine_owner: CharacterBody2D = null
var current_state: State = null
var current_state_name: String = ""
var prev_state: State = null
var states: Dictionary = {}
var state_textures: Dictionary = {}
var state_priority: Array[String] = []
var player_assets_folder_path: String = "res://Assets/Sprites/Player"
var prev_texture: Texture2D
func to_snake_case(input: String) -> String:
	var result := ""
	for i in input.length():
		var character := input[i]
		if character == character.to_upper() and character != character.to_lower() and i != 0:
			result += "_"
		result += character.to_lower()
	return result
func get_state_name(state: State = current_state) -> String:
	if state:
		return to_snake_case(state.name)
	return ""
func init_textures() -> void:
	var dir: DirAccess = DirAccess.open(player_assets_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and not ".import" in file_name:
				var texture_path: String = player_assets_folder_path + "/" + file_name
				var texture: Texture2D = load(texture_path)
				var texture_name: String = to_snake_case(file_name.get_basename())
				state_textures[states.get(texture_name)] = texture
			file_name = dir.get_next() 
		dir.list_dir_end()
func init_states() -> void:
	for state in get_children():
		states[to_snake_case(state.name)] = state
		state.machine_owner = machine_owner
		state.state_machine = self
func _ready() -> void:
	init_states()
	init_textures()
	state_priority = ["idle", "slide", "crouch", "run", "wall_slide", "hang", "jump", "fall"]
	change_state("idle")
	
func change_state(state_name: String) -> void:
	prev_texture = state_textures.get(current_state)
	if current_state:
		current_state.exit()
	current_state = states.get(state_name)
	current_state_name = state_name
	if current_state:
		current_state.enter()

func update(delta: float) -> void:
	
	for state_name in state_priority:
		if states.get(state_name).can_enter() and current_state != prev_state:
			change_state(state_name)
			break
	current_state.update(delta)
	if prev_texture != state_textures.get(current_state) and prev_texture != null:
		machine_owner.sprite_2d.texture = state_textures.get(current_state) 
		machine_owner.disable_colliders()
		if current_state_name == "slide":
			machine_owner.find_child("SlideCollider").disabled = false
			machine_owner.global_position.y += 8
		elif current_state_name == "crouch":
			machine_owner.find_child("CrouchCollider").disabled = false
			machine_owner.global_position.y += 10
		else:
			machine_owner.find_child("RegCollider").disabled = false
	
