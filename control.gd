extends Control


@onready var input = $VBoxContainer/LineEdit
@onready var team_list = $VBoxContainer/ScrollContainer/TeamList

func _ready():
	
	JavaScriptBridge.eval("console.log('JS bridge working')")
	JavaScriptBridge.eval("""
        window.godotReceiveTeams = function(data) {
            window._teamsData = data;
        }
	""")

func _process(_delta):
	if JavaScriptBridge.eval("window._teamsData != null"):
		var json = JavaScriptBridge.eval("window._teamsData")
		JavaScriptBridge.eval("window._teamsData = null")
		update_team_list(json)

func _on_add_team_pressed():
	var name = input.text.strip_edges()
	if name == "":
		return

	JavaScriptBridge.call("addTeam", name)

func update_team_list(json_string):
	var teams = JSON.parse_string(json_string)

	# Optional: sort by score descending
	teams.sort_custom(func(a, b): return a["score"] > b["score"])

	for child in team_list.get_children():
		child.queue_free()

	for team in teams:
		var row = HBoxContainer.new()

		var name_label = Label.new()
		name_label.text = team["name"]

		var score_label = Label.new()
		score_label.text = str(team["score"])

		var button = Button.new()
		button.text = "+1"
		button.pressed.connect(func():
			JavaScriptBridge.call("addScore", team["name"])
		)

		row.add_child(name_label)
		row.add_child(score_label)
		row.add_child(button)

		team_list.add_child(row)
