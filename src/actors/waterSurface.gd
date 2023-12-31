extends MeshInstance3D

var time := 0.0
var phaseX := 0.0
var phaseY := 0.0
var phaseZ := 0.0

func _ready():
	phaseX = randf()
	phaseY = randf()
	phaseZ = randf()

func _process(delta):
	time += delta
	position.y = 1+(1.0/8)*sin(time*PI/16)
	position.x = (1.0/4)*sin(time*PI/4)
	position.z = (1.0/4)*cos(time*PI/5)
	#rotate_y(sin(time*PI/32)*delta/100)
