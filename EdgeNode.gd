extends Node2D

const RESIDUE = 1.0
const DECAY = 0.5

var cities setget set_cities #array of the two cities being connected
var distance #the distance between the two cities
var direction = true #if true, label's movement will be towards first city
var move = false #if true, label will move along edge
var highlight = false #if true, edge and label will be highlighted red
var routeHighlight = false  #if true, edge is part of route and will be highlighted orange
var pheromone = 1.0 #pheromone level
var maxPhero = 1
var pheromoneHighlight = false #if true, edge will highlight green based on pheromone

onready var label = get_node("Label")
onready var line = get_node("LineDrawer")

func _ready():
	randomize()
	distance = randi() % 40  + 10
	label.text = str(distance)

func _process(_delta):
	label.text = str(distance) + "/" + str(pheromone)
	if move:
		var velocity = label.get_position()
		if direction:
			if(label.get_position().distance_to(cities[0].get_position()) > 40):
				velocity = velocity + velocity.direction_to(cities[0].get_position())
				label.set_position(velocity)
			else:
				direction = false
		else:
			if(label.get_position().distance_to(cities[1].get_position()) > 40):
				velocity = velocity + velocity.direction_to(cities[1].get_position())
				label.set_position(velocity)
			else:
				direction = true
	
	if highlight:
		line.default_color = Color.firebrick
		label.set("custom_colors/font_color", Color.firebrick)
	elif pheromoneHighlight:
		line.default_color = Color(0, (pheromone / maxPhero), 0)
		label.set("custom_colors/font_color", Color(0, (pheromone / maxPhero), 0))
	elif routeHighlight:
		line.default_color = Color.darkorange
		label.set("custom_colors/font_color", Color.darkorange)
	else:
		line.default_color = Color.black
		label.set("custom_colors/font_color", Color.black)

func set_cities(var cityA):
	cities = cityA
	label.set_position(midpoint(cities[0].get_position(), cities[1].get_position()))
	
	line.clear_points()
	line.add_point(cities[0].get_position())
	line.add_point(cities[1].get_position())

func midpoint(var vectA, var vectB):
	return Vector2((vectA.x + vectB.x) / 2, (vectA.y + vectB.y) / 2)

func update_pheromone():
	pheromone = DECAY * pheromone

func add_pheromone():
	pheromone += RESIDUE / distance
