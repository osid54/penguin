extends MeshInstance3D

var time := 0.0

func _process(delta):
	time += delta
	position.y = 1+(1.0/16)*sin(time*PI/16)
	position.x = (1.0/4)*sin(time*PI/4)
	position.z = (1.0/4)*cos(time*PI/5)
	#rotate_y(sin(time*PI/32)*delta/100)
