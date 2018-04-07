--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	local util = util
	local resource = resource
	local mysql = sr.MySQL
--

--
	util.AddNetworkString("SR_Tracker.SendTime")
	util.AddNetworkString("SR_Tracker.SendTimes")
	util.AddNetworkString("SR_Tracker.ChangePage")
	util.AddNetworkString("SR_Tracker.Search")
	util.AddNetworkString("SR_Tracker.ResetTime")
--

--
	if (config.UseWorkshop) then
		resource.AddWorkshop("1295948558")
	else
		resource.AddFile("materials/sr_tracker/cancel.png")
		resource.AddFile("resource/fonts/Lato-Bold.ttf")
	end
--

--
	local query = mysql:Create("sr_tracker_times")
		query:Create("steamid", "VARCHAR(255)")
		query:Create("time", "FLOAT")
		query:Create("firstjoin", "BIGINT")
		query:Create("lastjoin", "BIGINT")
		query:PrimaryKey("steamid")
	query:Execute()
--