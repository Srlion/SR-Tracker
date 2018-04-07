--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	config.UseWorkshop = true
--

--
	config.Command = "!times"
--

--
	config.ResultsPerPage = 30
--

--
	config.MenuPermissions = {
		["founder"] = true,
		["STEAM_0:0:150794857"] = true,
		[""] = true,
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
		CloseButton = Material("materials/sr_staff_manager/cancel.png", "noclamp smooth"),
	}
--