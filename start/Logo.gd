extends Control

@onready var glow = $Logo/Glow
@onready var logo = $Logo


# Called when the node enters the scene tree for the first time.
func _ready():
	firstStep()

func firstStep():
	var tween = get_tree().create_tween()
	tween.tween_property(glow, "modulate", Color(1,1,1,1), 1).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(logo, "modulate", Help.hexToColor("f74242"), 1).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(nextStep)

func nextStep():
	var tween = get_tree().create_tween()
	tween.tween_property(glow, "modulate", Color(1,1,1,0.3), 1).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(logo, "modulate", Help.hexToColor("ffffff"), 1).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(firstStep)

