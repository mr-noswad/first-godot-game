extends Area2D

var speed: float = 500.0
var direction: Vector2

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	LoggerGlobal.info(
		"cleared | ID: " + str(get_instance_id())
	)
	queue_free()


"This bullet flies out and if you hit something, that something becomes
the body variable and then checks if its in the mobs group.
Then deletes the body and then the bullet"
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		body.take_damage(50)
		LoggerGlobal.info(
			"Bullet hit Mob #" + str(body.mob_number)
		)
		queue_free()
