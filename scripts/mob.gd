extends RigidBody2D

var mob_number: int
# Called when the node enters the scene tree for the first time.
@export var max_health: int = 100
var health: int

func die() -> void:
	queue_free()

func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	health = max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	LoggerGlobal.info(
	"Mob #" + str(mob_number) +
	" READY | Health set to " + str(health)
)

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	$HealthBar.value = health
	LoggerGlobal.info(
		"Mob #" + str(mob_number) +
		" took " + str(amount) +
		" damage | HP: " + str(health)
	)
	if health <= 0:
		die()


	
func _on_visible_on_screen_notifier_2d_screen_exited():
	LoggerGlobal.info(
		"Mob #" + str(mob_number) +
		" cleared | ID: " + str(get_instance_id())
	)
	queue_free()
