extends Node

onready var cityCount_ctrl = get_node("ControlPanel/CityCount_Ctrl")
onready var cityHighlight_ctrl = get_node("ControlPanel/CityHighlight_Ctrl")
onready var cityMap = get_node("CityMap")

# Called when the node enters the scene tree for the first time.
func _ready():
	cityHighlight_ctrl.update_select(cityMap.LABELS.slice(0, cityMap.cityCount - 1))

func _on_BuildButton_pressed():
	cityMap.cityCount = cityCount_ctrl.cityCount
	cityMap.updateMap()
	cityMap.selected_highlight = 0
	
	cityHighlight_ctrl.update_select(cityMap.LABELS.slice(0, cityMap.cityCount - 1))

func _on_GreedyButton_pressed():
	# city array, edge array, and final route array
	var city_list = cityMap.cityHolder.get_children()
	var edge_list = cityMap.edgeHolder.get_children()
	
	# total number of cities and origin city
	var cityMAX = cityMap.cityCount #total number of cities
	var startCity = city_list[0] #origin city
	var nextCity
	
	# for every city, go to nearest city
	for c in range(cityMAX - 1):
		# save current city and remove it from city_list
		var currCity = city_list[0]
		city_list.remove(0)
		
		# current shortest edge
		var currEdge
		var minEdge = 50
		
		# search edges for a shortest edge
		for e in edge_list:
			if e.cities.has(currCity):
				if city_list.has(e.cities[0]) || city_list.has(e.cities[1]):
					if e.distance < minEdge:
						minEdge = e.distance
						currEdge = e
						
						if e.cities[0] == currCity:
							nextCity = e.cities[1]
						else:
							nextCity = e.cities[0]
		
		# highlight edge and remove it from edge_list
		currEdge.routeHighlight = true
		edge_list.erase(currEdge)
		
		# move next city to the front of city_list
		city_list.erase(nextCity)
		city_list.push_front(nextCity)
	
	for e in edge_list:
		if e.cities.has(startCity) && e.cities.has(nextCity):
			e.routeHighlight = true

func _on_MSTButton_pressed():
	var edge_list = MSTsort(cityMap.edgeHolder.get_children())
	var city_list = cityMap.cityHolder.get_children()
	var removed_cities = []
	var routeLength = city_list.size()
	var route = []
	
	# start with smallest route
	route.push_back(edge_list.pop_front())
	
	# find next route edge
	var minDist = 50
	var minEdge
	for e in edge_list:
		if route[0].cities.has(e.cities[0]) || route[0].cities.has(e.cities[1]):
			if e.distance < minDist:
				minDist = e.distance
				minEdge = e
				
	
	var currentCity
	if minEdge.cities.has(route[0].cities[0]):
		currentCity = route[0].cities[0]
		removed_cities.push_back(route[0].cities[1])
	else:
		currentCity = route[0].cities[1]
		removed_cities.push_back(route[0].cities[0])
	
	while route.size() < routeLength:
		minDist = 50
		for e in edge_list: # for every edge in edge_list
			if e.cities.has(currentCity): # if edge is connected to currentCity
				# if edge doesn't loop
				if !removed_cities.has(e.cities[0]) && !removed_cities.has(e.cities[1]):
					if e.distance < minDist:
						minDist = e.distance
						minEdge = e
		
		removed_cities.push_back(currentCity)
		if minEdge.cities[0] == currentCity:
			currentCity = minEdge.cities[1]
		else:
			currentCity = minEdge.cities[0]
		
		route.push_back(minEdge)
		edge_list.erase(minEdge)
	
	for r in route:
		r.routeHighlight = true

# sort an array of edges by distance
func MSTsort(var edge_list):
	var return_list = []
	
	while edge_list.size() > 0:
		var minDistance = 50
		var minEdge
		
		for e in edge_list:
			if e.distance < minDistance:
				minDistance = e.distance
				minEdge = e
		
		edge_list.erase(minEdge)
		return_list.push_back(minEdge)
	
	return return_list

func _on_AntColonyButton_pressed():
	var ants = [] #create and populate an array of all the edges that ants visit
	var numAnts = 20 #number of ants per cycle
	
	for e in cityMap.edgeHolder.get_children():
		e.update_pheromone()
	
	for no in range(numAnts):
		randomize()
		var edges = cityMap.edgeHolder.get_children() 
		var visited_cities = [] #array of visited cities, add random city first
		var numCities = cityMap.cityHolder.get_children().size()
		var currCity = cityMap.cityHolder.get_child(randi() % numCities)
		#print("**Start: ", currCity.cityName)
		
		for x in range(numCities - 1):
			var possible_edges = [] #find all the possible edges
			for e in edges:
				if e.cities.has(currCity):
					if !visited_cities.has(e.cities[0]) && !visited_cities.has(e.cities[1]):
						possible_edges.append(e)
						#print("-pos: ", e.distance)
			
			var probSum = 0.0
			var probs = [] #calculate probabilites for each possible edge
			for p in possible_edges:
				probs.append((p.pheromone / p.distance) + probSum)
				probSum += probs[-1]
			
			var rng = RandomNumberGenerator.new()
			var roll = rng.randf_range(0.0, probSum)
			var choice = 0
			while choice < probs.size() - 1 && roll < probs[choice]:
				choice += 1
			var edgeChoice = possible_edges[choice]
			#print("-choice: ", edgeChoice.distance)
			
			#add current city to visited_cities
			if currCity == edgeChoice.cities[0]:
				visited_cities.append(currCity)
				currCity = edgeChoice.cities[1]
			else:
				visited_cities.append(currCity)
				currCity = edgeChoice.cities[0]
			#print("City: ", currCity.cityName)
			
			ants.append(edgeChoice)
			edges.erase(edgeChoice)
		
		for e in edges:
			if e.cities.has(currCity) && e.cities.has(visited_cities[0]):
				ants.append(e)
				#print("LastE: ", e.distance)
	
	#update pheromone for all edges
	for e in ants:
		e.add_pheromone()
	
	#calculate highlight intensity
	var maxPheromone = 0
	for e in cityMap.edgeHolder.get_children():
		e.pheromoneHighlight = true
		maxPheromone = max(e.pheromone, maxPheromone)
	
	for e in cityMap.edgeHolder.get_children():
		e.maxPhero = maxPheromone
