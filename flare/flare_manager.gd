extends Node
# Autoload FlareManager

@export var flare_limit := 4

var flare_list : Array[Flare] = []

func register(flare: Flare) -> void:
	flare_list.append(flare)
	var flares_past_limit := flare_count() - flare_limit
	if (flares_past_limit > 0):
		for i in range(flares_past_limit):
			var f := flare_list.pop_front() as Flare
			if f: f.start_destroy()
			else: print_debug("""
			Too many flares, but also no flares, is the flare limit below zero?
			""")

func deregister(flare: Flare) -> void:
	var i = flare_list.find(flare)
	if i > -1:
		flare_list.remove_at(i)

func flare_count() -> int:
	return flare_list.size()
