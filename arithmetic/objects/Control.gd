extends Node2D

var t = 0
var total = 0
var target
var avoid
var score = 0
var player

var width  = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")
var rng = RandomNumberGenerator.new()
var symbols_sprite = load("res://sprites/symbols.png")
var score_text_sprite = load("res://sprites/score_text.png")


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	reroll()
	player = get_node("/root/Main/Player")

func _process(_delta):
	t += 1
	var period = 40
	if t >= period:
		t -= period
		
		var item = create(-16, rand_range(height/2, height), "res://objects/Item.tscn")
		var speed = 1.5
		if randf() < 0.5:
			item.speed.x = speed
		else:
			item.position.x = width - item.position.x
			item.speed.x = -speed
	
	# restart
	if Input.is_action_just_pressed("restart"):
		print("hi");
		get_tree().reload_current_scene()
		
		
func reroll():
	target = score
	avoid = score
	while target == score:
		target = rng.randi_range(-12, 12)
	while avoid == score or avoid == target:
		avoid = target + rng.randi_range(-3, 3)
	update() # CanvasItem.update, so _draw gets called again
		
func add_number(n):
	total += n
	if total == target:
		score += 1
		reroll()
	elif total == avoid:
		player.queue_free()
	
	update() # CanvasItem.update, so _draw gets called again



func _draw():
	var size = height/3
	draw_number(total, width/2, (height-size)/2, size, true, Color(1, 1, 1, 0.1))
	
	draw_texture_rect(score_text_sprite, Rect2(16, 16, 64, 16), false)
	draw_number(score, 16, 32, 16)
	
	var s = width*0.12
	draw_number(target, width/2-s, 32, 32, true)
	draw_number(avoid, width/2+s, 32, 32, true, Color(1, 0, 0, 1))

func draw_number(n, x, y, h, x_centered=false, color=Color(1,1,1,1)):
	var n_string = String(n)
	if x_centered: x -= n_string.length()*h/2
	
	for c in n_string:
		var digit
		if c == "-": digit = 10
		else: digit = int(c)
		draw_texture_rect_region(symbols_sprite, Rect2(x, y, h, h), Rect2(digit*32, 0, 32, 32), color)
		x += h



var resources = {}
func create(x, y, path):
	if !resources.has(path):
		resources[path] = load(path)
		
	var inst = resources[path].instance()
	add_child(inst)
	inst.position.x = x
	inst.position.y = y
	return inst
