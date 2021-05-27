extends ColorRect

#labels for all the cities
const LABELS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V']

var cityCount = 5 #number of cities
var selected_highlight = 0 #index of city to be highlighted

#city and edge holders (parents that hold all cities and edges as children)
onready var cityHolder = get_node("CityHolder")
onready var edgeHolder = get_node("EdgeHolder")

#preload city and edge scenes
var cityScene = preload("res://Scenes/CityNode.tscn")
var edgeScene = preload("res://Scenes/EdgeNode.tscn")

#update map with default settings at ready
func _ready():
	updateMap()

func updateMap():
	# delete all cities
	for n in cityHolder.get_children():
		cityHolder.remove_child(n)
		n.queue_free()
	
	# city ring parameters
	var radius = Vector2(0, -250)
	var origin = Vector2(300, 300)
	var spacing = 2 * PI / cityCount
	
	# add cities to ring/map
	for i in range(cityCount):
		var spawn = origin + radius.rotated(spacing * i)
		
		var cityInst = cityScene.instance()
		cityInst.set_cityName(LABELS[i])
		cityInst.position = spawn
		cityHolder.add_child(cityInst)
	
	# delete all edges
	for n in edgeHolder.get_children():
		edgeHolder.remove_child(n)
		n.queue_free()
	
	# add edges to map
	for x in range(cityHolder.get_children().size()):
		for y in range(x + 1, cityHolder.get_children().size()):
			var edgeInst = edgeScene.instance()
			edgeHolder.add_child(edgeInst)
			edgeHolder.get_child(edgeHolder.get_children().size() - 1).set_cities([cityHolder.get_child(x), cityHolder.get_child(y)])

# move edge labels 
func _on_MoveButton_button_down():
	for e in edgeHolder.get_children():
		e.move = true

# stop moving edge labels
func _on_MoveButton_button_up():
	for e in edgeHolder.get_children():
		e.move = false

# highlight selected city's edges
func _on_CityHighlight_button_down():
	for e in edgeHolder.get_children():
		if e.cities.has(cityHolder.get_child(selected_highlight)):
			e.highlight = true

# un-highlight edges
func _on_CityHighlight_button_up():
	for e in edgeHolder.get_children():
		e.highlight = false

# update selected city for highlight
func _on_CityHighlight_item_selected(index):
	selected_highlight = index

# un-highlight any marked routes
func _on_ClearRouteButton_pressed():
	for e in edgeHolder.get_children():
		e.routeHighlight = false
		e.pheromoneHighlight = false
		e.pheromone = 1.0
