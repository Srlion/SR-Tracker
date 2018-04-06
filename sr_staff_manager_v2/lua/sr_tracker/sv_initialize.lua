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
	-- util.AddNetworkString("SR_Tracker.SaveSetting")
--

--
	if (config.UseWorkshop) then
		resource.AddWorkshop("1295948558")
	else
		resource.AddFile("materials/sr_staff_manager/cancel.png")
		resource.AddFile("materials/sr_staff_manager/recycle.png")
		resource.AddFile("materials/sr_staff_manager/refresh.png")
		resource.AddFile("materials/sr_staff_manager/accept.png")
		resource.AddFile("resource/fonts/Lato-Bold.ttf")
	end
--

--
	local query = mysql:Create("sr_tracker_times")
		query:Create("id", "INT AUTO_INCREMENT")
		query:Create("steamid", "VARCHAR(255)")
		query:Create("time", "FLOAT")
		query:Create("firstjoin", "TEXT")
		query:Create("lastjoin", "TEXT")
		query:PrimaryKey("steamid")
	query:Execute()
--
