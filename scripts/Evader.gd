extends CharacterBody3D

# Save starting position
var start_position: Vector3

@onready var ray_n: RayCast3D = $North
@onready var ray_s: RayCast3D = $South
@onready var ray_e: RayCast3D = $East
@onready var ray_w: RayCast3D = $West
@onready var ray_ne: RayCast3D = $NorthEast
@onready var ray_nw: RayCast3D = $NorthWest
@onready var ray_se: RayCast3D = $SouthEast
@onready var ray_sw: RayCast3D = $SouthWest

@onready var tagger: CharacterBody3D = $"../Tagger"
@onready var tagging_box_3d: CollisionShape3D = $"../Tagger/TaggingBox/TaggingBox3D"
@onready var ai_controller: Node3D = $AIController3DEvader
	
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var raycasts: Array[RayCast3D] = []
# A list of true or false for when a raycast is colliding
var raycasts_colliding: Array[bool] = [];

func _ready():
	start_position = global_transform.origin
	raycasts = [ray_n, ray_s, ray_e, ray_w, ray_ne, ray_nw, ray_se, ray_sw]

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

	var input_dir := Input.get_vector("evader_left", "evader_right", "evader_up", "evader_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func on_tagged():
	reset_position()
	add_reward(-1)

func reset_position():
	global_transform.origin = start_position
	velocity = Vector3.ZERO
	
func add_reward(amount: float) -> void:
	if Global.ai_tagger:
		ai_controller.reward += amount
		# print("Evader: " + str(ai_controller.reward))
		
func get_raycast_distances() -> Dictionary:
	var distances := {}
	
	#Offset is to account for the raycast starting inside the cube
	var offset = 0.5
	for ray in raycasts:
		var dist: float
		if ray.is_colliding():
			dist = global_position.distance_to(ray.get_collision_point()) - offset
		else:
			dist = ray.target_position.length()
		
		if dist < 0:
			dist = 0
		
		distances[ray.name] = dist
	
	# print(distances)
	return distances
	
func get_amount_raycast_collided() -> int:
	var count = 0
	for has_collide in raycasts_colliding:
		if has_collide:
			count += 1
	return count
