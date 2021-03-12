extends Area2D

var n
var speed = Vector2()
var rng = RandomNumberGenerator.new()
var width  = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	rng.randomize()
	n = rng.randi_range(0, 9)
	$AnimatedSprite.frame = n

func _process(_delta):
	position += speed
	
	if position.x > width+64 or position.x<-64:
		queue_free()
