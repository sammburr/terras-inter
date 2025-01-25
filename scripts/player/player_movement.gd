extends CharacterBody3D

@export var camera : Camera3D
@export var body : Node3D
@export_flags_3d_physics var mouse_collision_mask : int

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		var ray_origin = camera.project_ray_origin(mouse_pos)

		var query = PhysicsRayQueryParameters3D.create(
			ray_origin, 
			ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
		
		)
		query.collision_mask = mouse_collision_mask
			
		var result : Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
		
		if !result.is_empty():
			body.look_at(Vector3(result.position.x, body.global_position.y, result.position.z))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
