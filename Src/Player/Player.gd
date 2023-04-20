extends CharacterBody3D

#movement variables

@export var walk_speed = 2.0
@export var run_speed = 5.0
@export var JUMP_VELOCITY = 10.5

var SPEED = 2.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#mouse settings
@export var mouse_sensitivity : float = 0.3
@export var min_pitch : float = -90
@export var max_pitch : float = 90

#camera movement
@onready var camera_pivot = $Head
@onready var camera = $Head/SpringArm3D/Camera3D
@onready var checkCast = $Head/CheckCast
@onready var effectCast = $Head/SpringArm3D/Camera3D/EffectCast

#magic moving
var magic_move_parent
var magic_moving = false
var magic_move_oneshot = false
var object_effect_force = 0
var max_object_effect_force = 50

#states

var running = false

var magic = false

var jumping_block = false
var just_jumped = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, min_pitch, max_pitch)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if camera.global_position.distance_to(effectCast.get_child(0).global_position) <= 99.0:
					effectCast.get_child(0).position.z -= 0.25
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if camera.global_position.distance_to(effectCast.get_child(0).global_position) >= 5.0:
					effectCast.get_child(0).position.z += 0.25
				
func _physics_process(delta):
	
	if effectCast.is_colliding():
		checkCast.look_at(effectCast.get_collision_point())
		
	# Add the gravity.
	if not is_on_floor():
		just_jumped = true
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		if magic == false:
			velocity.y = JUMP_VELOCITY
			just_jumped = true
	
	#handle jump block
	if just_jumped == true and self.is_on_floor():
		jumping_block = true
		await get_tree().create_timer(1).timeout
		jumping_block = false 
	
	if Input.is_action_just_pressed("cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if magic == false and jumping_block == false:
		var input_dir = Input.get_vector("A", "D", "W", "S")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			
		if Input.is_action_pressed("sprint"):
			SPEED = run_speed
			running = true
		else:
			SPEED = walk_speed
			running = false

		move_and_slide()
	_magic_move()



func _magic_move():
	if effectCast.get_child(0).get_child_count() == 1:
		effectCast.get_child(0).get_child(0).global_position = effectCast.get_child(0).global_position

	if magic_moving == true:
		if magic_move_oneshot == false:
			effectCast.get_child(0).get_child(0).set_linear_velocity(Vector3(0,0,0))
			magic_move_oneshot = true

	if Input.is_action_pressed("mouse_left"):
		if self.is_on_floor():
			magic = true
		else:
			magic = false
		if effectCast.is_colliding():
			if checkCast.is_colliding():
				if effectCast.get_collider().is_in_group("moveable"):
					if effectCast.get_child(0).get_child_count() == 0:
						effectCast.get_child(0).global_position = effectCast.get_collider().global_position
						magic_move_parent = effectCast.get_collider().get_parent()
						effectCast.get_collider().reparent(effectCast.get_child(0),true)
						magic_moving = true
	



	elif Input.is_action_pressed("mouse right"):
		if effectCast.get_child(0).get_child_count() > 0:
			if object_effect_force <= max_object_effect_force:
				object_effect_force += 1
			effectCast.get_child(0).get_child(0).apply_central_force(camera_pivot.global_transform.basis.z* -object_effect_force)
	else:
		if effectCast.get_child(0).get_child_count() > 0:
			effectCast.get_child(0).get_child(0).reparent(magic_move_parent,true)
			magic_move_parent = null
			magic_moving = false
			magic_move_oneshot = false
			object_effect_force = 0
		magic = false
	
