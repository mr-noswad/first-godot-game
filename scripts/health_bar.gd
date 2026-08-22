extends ProgressBar


@onready var timer = $Timer
@onready var damage_bar = $DamageBar

const HEALTHY_COLOUR := Color("#35d65a")
const LOW_HEALTH_COLOUR := Color("#f2d64b")
const BACKGROUND_COLOUR := Color("#1d2930")

var _fill_style: StyleBoxFlat

func _ready() -> void:
	_fill_style = StyleBoxFlat.new()
	_fill_style.corner_radius_top_left = 3
	_fill_style.corner_radius_top_right = 3
	_fill_style.corner_radius_bottom_left = 3
	_fill_style.corner_radius_bottom_right = 3
	add_theme_stylebox_override("fill", _fill_style)
	_update_colour(value)

var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	_update_colour(health)
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health
	
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _update_colour(current_health: float) -> void:
	var health_ratio: float = current_health / max(max_value, 1.0)
	_fill_style.bg_color = LOW_HEALTH_COLOUR if health_ratio <= 0.5 else HEALTHY_COLOUR


func _on_timer_timeout() -> void:
	damage_bar.value = health
