# Zachary Brent Ramos
# GAMDES1
# 10/10/2026
# player.gd
# Controls the Player: gravity, running, continuous jumping, single-press attack, sprite animations, and respawning.
extends CharacterBody2D

# --- Settings ---
const SPEED: float = 300.0
const JUMP_VELOCITY: float = -450.0

# --- Variables ---
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var is_attacking: bool = false

@export var animated_sprite: AnimatedSprite2D


# Runs once when the node enters the scene
func _ready() -> void:
	start_position = global_position
	add_to_group("player")


# Runs on physics frames (60fps)
func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Handle Jump (continuous hop when holding jump key)
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Handle Attack Input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		_perform_attack()

	# 4. Handle Horizontal Movement
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	# 5. Handle Sprite Animations & Horizontal Flipping
	if direction != 0:
		animated_sprite.flip_h = (direction < 0)

	# Only play movement animations if not mid-attack
	if not is_attacking:
		if not is_on_floor():
			animated_sprite.play("jump")
		elif direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

	# 6. Apply Movement & Collisions
	move_and_slide()


# Plays a single attack animation and waits until it finishes before returning control
func _perform_attack() -> void:
	is_attacking = true
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
		await animated_sprite.animation_finished
	else:
		await get_tree().create_timer(0.3).timeout
		
	is_attacking = false


# Resets the player position on enemy contact
func respawn() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	is_attacking = false
