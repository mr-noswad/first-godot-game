extends Node

@export var mob_scene: PackedScene
var score
# Called when the node enters the scene tree for the first time.

var mob_count: int = 0

func _ready() -> void:
	pass


func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	

func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()


func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	mob_count += 1
	"""
	We int mob number in mob then we have access to its variables
	"""
	mob.mob_number = mob_count
	LoggerGlobal.info(
	"Mob #" + str(mob.mob_number) + " spawned | ID: " + str(mob.get_instance_id())
)

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_player_shoot(Bullet, player_rotation, location, last_direction):
	var spawned_bullet = Bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = player_rotation
	spawned_bullet.position = location
	spawned_bullet.direction = last_direction

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()


# ============================================================
# COLLISION LAYERS & MASKS
# ============================================================
#
# Layer = What this object IS / which layer it exists on.
# Mask  = What this object DETECTS / which layers it looks for.
#
# Think:
#   Layer = "I am here"
#   Mask  = "I am looking for these"
#
# ------------------------------------------------------------
# Object   | Type          | Layer | Mask
# ------------------------------------------------------------
# Player   | Area2D        |   1   |   2
# Mob      | RigidBody2D   |   2   |  1,4
# Bullet   | Area2D        |   4   |   2
# ------------------------------------------------------------
#
# Player:
#   Layer 1 = Player
#   Mask 2  = detects Mobs
#
# Mob:
#   Layer 2 = Mob
#   Mask 1  = detects Player
#   Mask 4  = detects Bullets
#
# Bullet:
#   Layer 4 = Bullet
#   Mask 2  = detects Mobs
#
# Example:
#   Bullet (Layer 4)
#       ↓
#   Bullet Mask includes 2
#       ↓
#   Mob (Layer 2)
#       ↓
#   Collision detected
#
# IMPORTANT:
#   Layer numbers are just categories.
#   The Layer and Mask do NOT need to match.
# ============================================================
