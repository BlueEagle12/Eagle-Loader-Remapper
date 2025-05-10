	-- To create the definition and placement files use the blender script provided below, or just create your own.

	// 'definitions.definition', and 'placements.map'
		Place in "data" folder
		
	// Dffs, Cols, Txds
		Place in "resources" folder
	
	// Config
		- Open "Config.lua",
			- Set mapName
			- Set mAuthor
			- Map Offset
		
	// Running the map
		After you have everything setup start the 'eagleMapProccessor" as a resource, and it'll 
		export the map into Output "Or whatever you named the map", place this in your resources, 
		start the 'eagleLoader' resource then start your map, and it should load.

		If you're having issues read the output log "debug.txt" and will tell you any issues that occured
		during map proccessing.
		
