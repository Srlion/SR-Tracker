--
	local sr = SR_Tracker
	local config = sr.Config
--

-- Do you want to use workshop
	config.UseWorkshop = true
--

-- Command to open times menu
	config.Command = "!times"
--

-- Results to show per page
	config.ResultsPerPage = 60
--

-- You can use group, steamid and steamid64
	config.MenuPermissions = {
		["founder"] = true,
		["STEAM_0:0:150794857"] = true
	}
--

--
	config.Colors = {
		HUDBackground = Color(65, 185, 255),
		HUDTexts = Color(255, 255, 255),

		Header = Color(65, 185, 255),
		HeaderTextColor = Color(255, 255, 255),

		Background = Color(126, 138, 153),
		BackgroundList = Color(255, 255, 255),

		CloseButtonHover = Color(255, 60, 60),
		
		SearchBarBackground = Color(65, 185, 255),
	}
--

--
	config.Languages = {
		FullTime = "Play Time: %s",
		SessionTime = "Session Time: %s",

		Drag = "Drag",
		Close = "Close",
		
		Reset = "Reset",
	}
--

--
	config.Materials = {
		CloseButton = Material("materials/sr_tracker/cancel.png", "noclamp smooth"),
	}
--
