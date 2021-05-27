extends Node2D

var cityName setget set_cityName #label of city

onready var cityLabel = get_node("Label")

func _ready():
	update_label(cityName)

# draw circle with a random color to represent city
func _draw():
	randomize()
	var randomColor = Color(randf(), randf(), randf())
	draw_circle(Vector2.ZERO, 15, randomColor)

# setter for cityName
func set_cityName(newName):
	cityName = newName

# change label text
func update_label(newLabel):
	cityLabel.text = newLabel
