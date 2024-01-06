extends CharacterBody3D


@export var accel := 1.0
@export var maxSpeed := 5.0
@export var rotSpeed := 3.0

@export var jumpV := 4.5

var gravity = 15

var rotating = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = jumpV

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_axis("forward","backward")
	
	#TODO
	var speed := maxSpeed
	if input_dir > 0: speed = maxSpeed/2
	else: speed = maxSpeed
	
	var rot_dir = Input.get_axis("right","left")
	$camPivot.rotate(Vector3(0,1,0),delta*rot_dir*2)
	var direction = (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		var rotNeeded = calcRotNeeded()
		if abs(rotNeeded/PI*180) >= 10:
			rotate_y(rotNeeded*delta*rotSpeed)
			$camPivot.rotate_y(-1*rotNeeded*delta*rotSpeed)
			
		velocity.x = move_toward(velocity.x, direction.x * speed, accel)
		velocity.z = move_toward(velocity.z, direction.z * speed, accel)

	else:
		velocity.x = move_toward(velocity.x, 0, accel)
		velocity.z = move_toward(velocity.z, 0, accel)
	
	$penguin/AnimationTree.set("parameters/Blend2/blend_amount", sqrt(velocity.x**2+velocity.z**2)/maxSpeed)

	move_and_slide()

func calcRotNeeded():
	var rot = $camPivot.global_rotation.y - global_rotation.y
	if rot > PI: rot -= TAU
	if rot < -PI: rot += TAU
	if rot > 0: rot = 1
	elif rot < 0: rot = -1
	else: rot = 0
	return rot
