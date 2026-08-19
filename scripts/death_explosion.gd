extends AnimatedSprite2D


func time_to_die() -> void:
	show()
	play()
	await animation_finished
	hide()
	
