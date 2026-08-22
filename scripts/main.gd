extends Node

@export var mob_scene: PackedScene
@export var ammo_scene: PackedScene
@export var debug_mode: bool = false
@onready var healthbar = $HUD/HealthBar
var score
var kill_count: int = 0
@onready var ammo_spawn: Marker2D = $AmmoSpawn

var mob_count: int = 0

"We emit a signal in the player script, we click the player child node here and create the signal connection
then when hit, game over runs"
func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	
func spawn_ammo():
	var crate = ammo_scene.instantiate()
	add_child(crate)
	crate.global_position = ammo_spawn.global_position

func spawn_debug_mobs() -> void:
	if debug_mode:
		var spawn_positions = [$debug1.global_position, $debug2.global_position ,$debug3.global_position]
		for spawns in spawn_positions:
			var mob = mob_scene.instantiate()
			add_child(mob)
			mob.global_position = spawns
	
func new_game():
	"""
	We want the players health to be apart of the hud. We add the healthbar as a child to the hud. 
	We call that child node with the var at the top. we already added the HUD node to the scene. 
	We init that health bar with the players max health below. 
	
	in take_damage we 
	health_changed.emit(health)
	
	Then we connect that signal to here from the player node in main
	
	func update_player_health(new_health):
	healthbar.health = new_health
	"""
	healthbar.init_health($Player.max_health)
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()
	spawn_debug_mobs()

func _on_mob_timer_timeout() -> void:
	if debug_mode:
		return
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
	
	"""
	We connect the signals at runtime. SCENE SIGNAL CONNECT (NODE FUNCTION)
	We remove the () at the end so it does not get run instantly
	"""
	mob.mob_death.connect(update_kill_count)

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

func update_kill_count() -> void:
	kill_count += 1
	$HUD.update_kill_count(kill_count)

func update_player_health(new_health):
	healthbar.health = new_health
	



# ==================================================_on_player_health_changed==========
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
