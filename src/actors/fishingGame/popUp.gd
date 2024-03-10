extends Node2D

@export var target : PackedScene
@export var rotateSpeed := 2
var targets := []
var radius := 182
var moving := false
var rot := 1.5 * PI
var hits := 0

func _ready():
	position = Vector2(int(get_window().get_size().x/2.0),int(get_window().get_size().y/2.0))
	
func _process(delta):		
	checkHit()
		
	if rot >= TAU:
		rot -= TAU
		
	if moving:
		rot += rotateSpeed * delta
		#$lineHolder.rotation = rot
		$lineHolder.rotate(rotateSpeed * delta)

	#print(rot)

func checkCollisions(t: float) -> bool:
	if abs(t - 1.5 * PI) < PI/8.0:
		return false
	for tar in targets:
		if (abs(t - tar.angle) < tar.size()/radius or 
		abs(t - tar.angle) > TAU - tar.size()/radius):
			return false
	return true
		
func clear():
	for child in $targets.get_children():
		child.queue_free()
	targets.clear()
	hits = 0

func create():
	position = Vector2(int(get_window().get_size().x/2.0),int(get_window().get_size().y/2.0))
	moving = false
	clear()
	$lineHolder.rotation = 0
	rot = 1.5 * PI
	startMove()
	for i in randi_range(1,5):
		var t = target.instantiate()
		t.num = targets.size()
		t.angle = randf_range(0,TAU)
		while !checkCollisions(t.angle):
			t.angle = randf_range(0,TAU)
		t.position = Vector2(radius*cos(t.angle),radius*sin(t.angle))
		t.rotateSprite(t.angle)
		targets.append(t)
		$targets.add_child(t)
	targets.sort_custom(targetSort)
	#print("order")
	#for t in targets:
		#print(t.angle)

func checkAction():
	if Input.is_action_just_pressed("forward"): return "w"
	if Input.is_action_just_pressed("left"): return "a"
	if Input.is_action_just_pressed("backward"): return "s"
	if Input.is_action_just_pressed("right"): return "d"
	if Input.is_action_just_pressed("space"): return "_"
	return ""

func checkHit():
	for t in targets:
		if abs(t.angle - rot) < $lineHolder/indicator.get_rect().size.x/radius + 5*PI/180:
			if !t.big:
				t.sizeUp()
			if checkAction() == t.reqInput:
				t.modulate = "GREEN"
				hits+=1
				if hits == len(targets):
					visible = false
					clear()
		else:
			if t.big:
				t.sizeDown()
				
func targetSort(a, b):
	var ang1 = a.angle
	var ang2 = b.angle
	if ang1 > 1.5*PI:
		ang1 -= TAU
	if ang2 > 1.5*PI:
		ang2 -= TAU
	if ang1 < ang2:
		return true
	return false

func startMove():
	await get_tree().create_timer(1).timeout
	moving = true
