extends Area2D

func _on_area_entered(area: Area2D) -> void:
	LoggerGlobal.info("has entered AMMO")
	if area.is_in_group("player"):
		area.ammo += 10
		area.no_ammo_bool = false
		queue_free()
