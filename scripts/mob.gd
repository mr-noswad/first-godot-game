extends RigidBody2D

var mob_number: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()

func _on_visible_on_screen_notifier_2d_screen_exited():
	LoggerGlobal.info(
		"Mob #" + str(mob_number) +
		" cleared | ID: " + str(get_instance_id())
	)
	queue_free()
