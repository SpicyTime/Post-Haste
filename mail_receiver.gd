extends Area2D

	


func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body is CharacterBody2D:
		#If the player has mail we take 1 away and free the mail receiver object
		if GameManager.player_mail_count > 0:
			GameManager.set_mail_count(GameManager.player_mail_count - 1)
			queue_free()
