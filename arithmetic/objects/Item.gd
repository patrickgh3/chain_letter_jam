extends Area2D

var n
var speed = Vector2()
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	n = rng.randi_range(0, 9)
	$AnimatedSprite.frame = n

func _process(_delta):
	position += speed
