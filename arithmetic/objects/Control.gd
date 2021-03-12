extends Node2D

var period = 40
var t = period-1
var total = 0
var target
var num_avoids = 2
var avoids
var score = 0
var player

var width  = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")
var rng = RandomNumberGenerator.new()
var symbols_sprite = load("res://sprites/symbols.png")
var score_text_sprite = load("res://sprites/score_text.png")

var collect_sounds = [load("res://sounds/chalk1.wav"),
	load("res://sounds/chalk2.wav"),
	load("res://sounds/chalk3.wav"),
	load("res://sounds/chalk4.wav")]
var win_sounds = [load("res://sounds/chalk_win1.wav"),
	load("res://sounds/chalk_win2.wav"),
	load("res://sounds/chalk_win3.wav")]
var lose_sounds = [load("res://sounds/chalk_lose1.wav"),
	load("res://sounds/chalk_lose2.wav")]
var jump_sounds = [load("res://sounds/chalk_jump.wav")]


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	reroll()
	player = get_node("/root/Main/Player")
	play_random_sound_from_array(jump_sounds)

func _process(_delta):
	t += 1
	if t >= period:
		t -= period
		
		var item = create(-16, rand_range(height/2, height-16), "res://objects/Item.tscn")
		var speed = 1.5
		if randf() < 0.5:
			item.speed.x = speed
		else:
			item.position.x = width - item.position.x
			item.speed.x = -speed
	
	# restart
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	# toggle hard mode
	if Input.is_action_just_pressed("hard_mode"):
		Global.hard_mode = not Global.hard_mode
		get_tree().reload_current_scene()



func reroll():
	target = score
	while target == score:
		target = rng.randi_range(-12, 12)
	
	if Global.hard_mode:
		avoids = [choose_from_array([target-3, target-2, target-1]),
				  choose_from_array([target+1, target+2, target+3])]
	else:
		avoids = [choose_from_array([target-3, target-2, target-1,
				  target+1, target+2, target+3])]
	
	update() # CanvasItem.update, so _draw gets called again
		
func add_number(n):
	total += n
	
	var hit_avoid = false;
	for avoid in avoids:
		if total == avoid:
			hit_avoid = true;
			break;
	
	if total == target:
		score += 1
		reroll()
		play_random_sound_from_array(win_sounds)
	elif hit_avoid:
		player.queue_free()
		play_random_sound_from_array(lose_sounds)
	else:
		play_random_sound_from_array(collect_sounds)
	
	update() # CanvasItem.update, so _draw gets called again
	
func play_random_sound_from_array(array):
	$AudioStreamPlayer.stream = choose_from_array(array)
	$AudioStreamPlayer.pitch_scale = rand_range(0.9, 1.1)
	$AudioStreamPlayer.play()
	
func choose_from_array(array):
	var i = rng.randi_range(0, array.size()-1)
	return array[i]



func _draw():
	var size = height/3
	draw_number(total, width/2, (height-size)/2, size, true, Color(1, 1, 1, 0.1))
	
	draw_texture_rect(score_text_sprite, Rect2(16, 16, 64, 16), false)
	draw_number(score, 16, 32, 16)
	
	var s = width*0.12
	draw_number(target, width/2-s, 32, 32, true)
	var y = 32
	for avoid in avoids:
		draw_number(avoid, width/2+s, y, 32, true, Color(1, 0, 0, 1))
		y += 32

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
