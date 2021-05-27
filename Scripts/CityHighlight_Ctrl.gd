extends HBoxContainer

# controls UI for highlighting a selected city's routes

var curr_select

onready var select = get_node("CityHighlight_Select")

func _ready():
	pass # Replace with function body.

func update_select(var cities):
	select.clear()
	
	for c in cities:
		select.add_item(str(c))
	
	curr_select = 0
	select.select(0)
