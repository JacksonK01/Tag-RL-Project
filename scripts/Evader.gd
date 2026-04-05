extends CharacterBody3D

# Save starting position
var start_position: Vector3
func _ready():
	start_position = global_transform.origin
	
@onready var tagger: CharacterBody3D = $"../Tagger"
@onready var tagging_box_3d: CollisionShape3D = $"../Tagger/TaggingBox/TaggingBox3D"

	
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("evader_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("evader_left", "evader_right", "evader_up", "evader_down") # These UI actions are mapped to WASD
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func reset_position():
	global_transform.origin = start_position
	velocity = Vector3.ZERO
	
func _on_tagging_box_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body is CharacterBody3D:
		reset_position()
		tagger.reset_position()

	
