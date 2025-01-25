extends CharacterBody3D

@export_category("REFERENCES")
@export var camera : Camera3D
@export var body : Node3D
@export var ui : PlayerUI
@export_category("SETTINGS")
@export_flags_3d_physics var mouse_collision_mask : int
@export var base_speed : float = 5.0
@export var dash_speed : float = 15.0
@export var time_per_stamina : int
@export var walk_speed_recovery : float = 2.0

const JUMP_VELOCITY = 4.5

var stamina_timer : Timer
var current_speed : float

func _ready() -> void:
	current_speed = base_speed
	
	stamina_timer = Timer.new()
	stamina_timer.wait_time = time_per_stamina
	stamina_timer.autostart = true
	stamina_timer.timeout.connect(_recharge_stamina)
	add_child(stamina_timer)

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
			
	elif Input.is_action_just_pressed("dash"):
		ui.sprint_charges.try_use_charge()
		current_speed = dash_speed
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.global_position += camera.global_basis.z
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.global_position -= camera.global_basis.z
			


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Lerp curretn speed back to normal.
	current_speed = lerpf(current_speed, base_speed,   delta / walk_speed_recovery)
	ui.speed_text_label.text = "Speed: " + str(round(current_speed * 100)/100)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func _recharge_stamina() -> void:
	ui.sprint_charges.try_recharge()
	pass
	
