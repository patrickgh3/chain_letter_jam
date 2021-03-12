extends Area2D

var speed = Vector2()
var djump = true
var item_class = load("res://objects/Item.gd")
var jump_speed = -5.5
var minus = false
var control

func _ready():
	speed.y = -3
	control = get_node("/root/Main/Control")
	print(control)

func _process(_delta):
	var d = Vector2()
	if Input.is_action_pressed("ui_right"):
		d.x = 4
	if Input.is_action_pressed("ui_left"):
		d.x = -4
	speed.x = d.x
	
	# down
	if Input.is_action_pressed("ui_down") :
		speed.y += 0.25
		
	# gravity
	speed.y += 0.07
	
	# clamp y speed
	if speed.y > 3: speed.y = 3
	
	# jump
	if Input.is_action_just_pressed("jump") and djump:
		speed.y = jump_speed
		djump = false
	# release jump
	if Input.is_action_just_released("jump") and speed.y < 0:
		speed.y *= 0.5
		
	# move
	position += speed
	
	
		
	# switch plus and minus
	if Input.is_action_just_pressed("action"):
		minus = not minus

	# flip sprite
	if speed.x > 0: $AnimatedSprite.flip_h = false
	if speed.x < 0: $AnimatedSprite.flip_h = true
	
	# sprite frame
	if speed.y < 0:
		$AnimatedSprite.frame = 0
	else:
		$AnimatedSprite.frame = 1
	if minus:
		$AnimatedSprite.frame += 2


func _on_player_area_entered(other):
	if other.get_script() == item_class:
		other.queue_free()
		speed.y = jump_speed
		djump = true
		
		var n = other.n
		if minus:  n *= -1
		control.add_number(n)
