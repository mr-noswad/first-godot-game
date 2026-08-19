extends Area2D

signal hit
var screen_size # Size of the game window.

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var bullet_scene: PackedScene
@onready var healthbar = $HealthBar
@export var max_health: int = 100


var health: int
var is_dying := false


signal shoot(bullet, direction, location)
var last_direction: Vector2 = Vector2.UP
var player_bullet_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LoggerGlobal.info("Player script is running")
	health = max_health
	healthbar.init_health(health)
	screen_size = get_viewport_rect().size # If you change this it should be a camera2d node and have the script there.
	hide()
	$death_animation.hide()

func movement(velocity):
	if velocity.x != 0 and velocity.y != 0:
		$AnimatedSprite2D.animation = "up"

	# Up-right
	if velocity.x > 0 and velocity.y < 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.rotation = PI / 4

	# Up-left
	elif velocity.x < 0 and velocity.y < 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.rotation = -PI / 4

	# Down-right
	elif velocity.x > 0 and velocity.y > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_v = true
		$AnimatedSprite2D.rotation = -PI / 4

	# Down-left
	elif velocity.x < 0 and velocity.y > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_v = true
		$AnimatedSprite2D.rotation = PI / 4

# Horizontal movement
	elif velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.rotation = 0
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0

# Vertical movement
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.rotation = 0
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_v = velocity.y > 0
"""

We dont use degrees in game engines, we use radians instead. 

Degrees        Radians

360°     =     2 PI
180°     =     PI
90°      =     PI / 2
45°      =     PI / 4
22.5°    =     PI / 8
"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		last_direction = velocity.normalized()
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if Input.is_action_just_pressed("shoot"):
		shoot.emit(bullet_scene, rotation, position, last_direction)

	movement(velocity)

func reset() -> void:
	is_dying = false
	$AnimatedSprite2D.show()
	$CollisionShape2D.set_deferred("disabled", false)


func die() -> void:
	if is_dying:
		return
	is_dying = true

	LoggerGlobal.info("Player is dead")
	$AnimatedSprite2D.hide() # Player disappears after being hit.
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	
	$death_animation.time_to_die()
	
func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	healthbar.health = health
	LoggerGlobal.info(
		"Player took " + str(amount) +
		" damage | HP: " + str(health)
	)
	if health <= 0:
		die()

"""
I dont call body.take_damage here because I want damage on myself. 
"""
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		take_damage(25)


func start(pos):
	health = max_health
	healthbar.init_health(health)
	is_dying = false
	position = pos
	show()
	$AnimatedSprite2D.show()
	$CollisionShape2D.disabled = false
