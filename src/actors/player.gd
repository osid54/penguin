extends CharacterBody3D


@export var accel := 1.0
@export var maxSpeed := 5.0

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_axis("forward","backward")
	var rot_dir = Input.get_axis("right","left")
	rotate(Vector3(0,1,0),rot_dir/20)
	var direction = (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * maxSpeed, accel)
		velocity.z = move_toward(velocity.z, direction.z * maxSpeed, accel)

	else:
		velocity.x = move_toward(velocity.x, 0, accel)
		velocity.z = move_toward(velocity.z, 0, accel)
	
	$penguin/AnimationTree.set("parameters/Blend2/blend_amount", sqrt(velocity.x**2+velocity.z**2)/maxSpeed)

	move_and_slide()
