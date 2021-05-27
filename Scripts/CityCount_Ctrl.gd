extends HBoxContainer

# controls UI for adjusting number of cities

var cityCount = 5 #number of cities

onready var cityCount_Label = get_node("CityCount_No")

func _ready():
	updateLabel()

# update label when subtracted
func _on_CityCount_Sub_pressed():
	if(cityCount > 5):
		cityCount -= 1
	updateLabel()

# update label when subtracted
func _on_CityCount_Add_pressed():
	if(cityCount < 20):
		cityCount += 1
	updateLabel()

# match label with city count
func updateLabel():
	cityCount_Label.text = str(cityCount)
