# Zachary Brent Ramos
# GAMDES1
# 10/10/2026
# enemy.gd
# Controls the enemy: faces left, plays attack animation on contact, delays respawn until hit frames, then resets player.
extends CharacterBody2D

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false


# _ready() runs once when the Enemy enters the scene
func _ready() -> void:
	# Make enemy face left by default
	if animated_sprite:
		animated_sprite.flip_h = true
		animated_sprite.play("idle")
	
	# Connect the Hitbox overlap signal
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)


# Runs when something enters the Hitbox area sensor
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Checks if the entering body is the player or in the player group
	if (body.is_in_group("player") or body.name == "Player") and not is_attacking:
		is_attacking = true
		print("Enemy attacking player!")
		
		# 1. Play attack animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack"):
			animated_sprite.play("attack")
		
		# 2. DELAY: Wait for the attack swipe to reach the player (adjust 0.3s to match your hit frame)
		await get_tree().create_timer(0.3).timeout
		
		# 3. RESPAWN: Reset the player position AFTER the attack hits
		if body.has_method("respawn"):
			body.respawn()
		else:
			body.global_position = Vector2(150, 500)
		
		# 4. Wait for the rest of the attack recovery animation before returning to idle
		await get_tree().create_timer(0.2).timeout
		
		# 5. Reset enemy to idle state
		if animated_sprite:
			animated_sprite.play("idle")
			
		is_attacking = false
