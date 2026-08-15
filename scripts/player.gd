extends Area2D

signal hit
var screen_size # Size of the game window.

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var bullet_scene: PackedScene

var last_direction: Vector2 = Vector2.DOWN
var player_bullet_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LoggerGlobal.info("Player script is running")
	screen_size = get_viewport_rect().size
	hide()

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
	if Input.is_action_just_pressed("shoot"):
		"""
		At the top @export var bullet_scene: PackedScene
		We add the bullet scene in the ui to the right after the top is done
		Add the "Bullets" 2d node and add the bullet as a child
		
		Global position refers to globabl position of this script, the player
		
		So bullet pos = players global pos
		so if we were in a different script that would be the global pos
		and the bullet dir is equal the velocity which is above. 
		
		"""
		var bullet: Area2D = bullet_scene.instantiate()
		get_parent().get_node("Bullets").add_child(bullet)
		bullet.global_position = global_position
		bullet.direction = velocity
		player_bullet_count += 1
		LoggerGlobal.info(
			"Player Bullet #" + str(player_bullet_count) + " spawned | ID: " + str(bullet.get_instance_id()))
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		last_direction = velocity.normalized()
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	movement(velocity)

	

func _on_body_entered(_body: Node2D) -> void:
	LoggerGlobal.info("Player is dead")
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
