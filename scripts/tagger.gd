extends CharacterBody3D

# Save starting position
var start_position: Vector3
func _ready():
	start_position = global_transform.origin

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ai_controller: Node3D = $AIController3DTagger

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Global.ai_tagger:
		ai_controls(delta)
	else:
		human_controls(delta)
		
	move_and_slide()
		
func ai_controls(delta: float) -> void:
	velocity.x = ai_controller.move.x
	velocity.z = ai_controller.move.y
	
func human_controls(delta: float) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") # Arrow keys
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
func on_tagged():
	reset_position()
	add_reward(1.0)

func reset_position():
	global_transform.origin = start_position
	velocity = Vector3.ZERO
	
func add_reward(amount: float) -> void:
	if Global.ai_tagger:
		ai_controller.reward += amount
		print("Tagger: " + str(ai_controller.reward))
