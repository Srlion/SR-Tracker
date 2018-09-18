local SR = SR_Tracker
local config = SR.Config

-- Command to open times menu
config.Command = "!times"

-- Results to show per page
config.ResultsPerPage = 60

-- HUD position, choose between: Top, TopRight, TopLeft, Bottom, BottomRight, BottomLeft
config.HUDPosition = "TopRight"

-- You can use group, steamid and steamid64
config.MenuPermissions = {
	["founder"] = true,
	["superadmin"] = true,
	["76561198261855442"] = true,
	["STEAM_0:0:150794857"] = true
}

-- HUD Colors
config.Colors = {
	HUDBackground = Color(65, 185, 255),
	HUDTexts = Color(255, 255, 255)
}

config.Languages = {
	FullTime 	= "Play Time: %s",
	SessionTime = "Session Time: %s",

	Drag 	= "Drag",
	Close	= "Close",

	Reset 			= "Reset",
	CopySteamID 	= "Copy SteamID",
	CopySteamID64 	= "Copy SteamID64",

	Search = "Search...",

	LastPage = "Last Page",
	CurrPage = "Page: %d/%d",
	NextPage = "Next Page",

	SteamID 	= "SteamID",
	PlayTime 	= "Play Time",
	LastJoin 	= "Last Join",
	FirstJoin	= "First Join",
	Online 		= "Online",

	Yes = "Yes",
	No 	= "No"
}