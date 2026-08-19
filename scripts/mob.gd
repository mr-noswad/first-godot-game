extends RigidBody2D

var mob_number: int
# Called when the node enters the scene tree for the first time.
@export var max_health: int = 100
@onready var healthbar = $HealthBar
var health: int
var is_dying := false
signal mob_death

func die() -> void:
	if is_dying:
		return
	is_dying = true

	$AnimatedSprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("freeze", true)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	$death_animation.time_to_die()
	$HealthBar.queue_free()
	mob_death.emit()

func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	$death_animation.hide()
	health = max_health
	healthbar.init_health(health)
	LoggerGlobal.info(
	"Mob #" + str(mob_number) +
	" READY | Health set to " + str(health)
)

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	healthbar.health = health
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
