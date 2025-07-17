extends Node
var player_mail_count: int = 0 : set = set_mail_count

func set_mail_count(value: int) -> void:
	player_mail_count = value
	SignalManager.mail_count_changed.emit(player_mail_count)
