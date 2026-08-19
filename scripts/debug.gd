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
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()
	$Player.reset()
	

func spawn_debug_mobs() -> void:
	var spawn_positions = [$debug1.global_position, $debug2.global_position ,$debug3.global_position]
	for spawns in spawn_positions:
		var mob = mob_scene.instantiate()
		add_child(mob)
		mob.global_position = spawns


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
	spawn_debug_mobs()
