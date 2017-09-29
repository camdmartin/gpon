extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var screen_size
var pad_size
var direction = Vector2(1.0, 0.0)

# Constant for ball speed (in pixels/second)
const INITIAL_BALL_SPEED = 100
# Speed of the ball (also in pixels/second)
var ball_speed = INITIAL_BALL_SPEED
# Constant for pads speed
const PAD_SPEED = 300
# Number of gravity nodes
const NODES = 8

func _ready():
	screen_size = get_viewport_rect().size
	pad_size = get_node("left").get_texture().get_size()
	
	randomize()
	
	make_attractor()
	
	set_process(true)

func _process(delta):
	var ball_pos = get_node("ball").get_pos()
	var left_rect = Rect2(get_node("left").get_pos() - pad_size*0.5, pad_size)
	var right_rect = Rect2(get_node("right").get_pos() - pad_size*0.5, pad_size)
	
	ball_pos += direction * ball_speed * delta
	
	if ((ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0)):
    	direction.y = -direction.y
	
	if (left_rect.has_point(ball_pos) and direction.x < 0.0) or (right_rect.has_point(ball_pos) and direction.x > 0):
		direction.x = -direction.x
		direction.y = randf()*2.0 - 1
		ball_speed += 20

	if (ball_pos.x < 0 or ball_pos.x > screen_size.x):
		
		var serve_dir = 1
		
		if ball_pos.x < 0:
			var p2 = get_node("p2score")
			serve_dir = 1
			p2.set_text(String(int(p2.get_text()) + 1))
			
		if ball_pos.x > screen_size.x:
			var p1 = get_node("p1score")
			serve_dir = -1
			p1.set_text(String(int(p1.get_text()) + 1))
			
		ball_pos = screen_size*0.5
		ball_speed = INITIAL_BALL_SPEED
		direction = Vector2(1 * serve_dir, 0)
		
		make_attractor()

	for s in get_tree().get_nodes_in_group("gravitic"):
		var grav_strength = 2 / pow((get_node("ball").get_pos().distance_to(s.get_pos()) + 0.1), 1.1)
		if s.get_pos().y > ball_pos.y:
			direction = Vector2(direction.x, direction.y + grav_strength)
		if s.get_pos().y < ball_pos.y:
			direction = Vector2(direction.x, direction.y - grav_strength)

	get_node("ball").set_pos(ball_pos)
	
	var left_pos = get_node("left").get_pos()

	if (left_pos.y > 0 and Input.is_action_pressed("left_move_up")):
	    left_pos.y += -PAD_SPEED * delta
	if (left_pos.y < screen_size.y and Input.is_action_pressed("left_move_down")):
	    left_pos.y += PAD_SPEED * delta
	
	get_node("left").set_pos(left_pos)
	
	var right_pos = get_node("right").get_pos()
	
	if (right_pos.y > 0 and Input.is_action_pressed("right_move_up")):
	    right_pos.y += -PAD_SPEED * delta
	if (right_pos.y < screen_size.y and Input.is_action_pressed("right_move_down")):
	    right_pos.y += PAD_SPEED * delta
	
	get_node("right").set_pos(right_pos)
	
func make_attractor():
	var n = load("res://grav.tscn").instance()
	add_child(n)
	n.add_to_group("gravitic")
	n.set_pos(Vector2(randi() % int(screen_size.x), randi() % int(screen_size.y)))