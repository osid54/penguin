extends Node3D

var time := 0.0
var phase := 0.0
var startPosX := 0.0
var startPosZ := 0.0

func _ready():
	phase = randf()
	startPosX = position.x
	startPosZ = position.z

func _process(delta):
	time += delta
	position.y = 1+(1.0/16)*sin(time*PI/16)
	position.x = startPosX + (1.0/8)*sin(time*PI/8+phase*PI)
	position.z = startPosZ + (1.0/8)*cos(time*PI/10+phase*PI)
	$innerMesh.scale = Vector3(abs(sin(time*PI/4+phase*PI)), 1, abs(sin(time*PI/4+phase*PI)))
