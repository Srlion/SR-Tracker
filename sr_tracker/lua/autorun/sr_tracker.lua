SR_Tracker = {}
SR_Tracker.Config = {}

if (SERVER) then
	include("sr_tracker/sv_mysql.lua")

	hook.Add("SR_Tracker.DatabaseConnected", "SR_Tracker.Initialize", function()
		include("sr_tracker_config.lua")
		include("sr_tracker/sh_pon.lua")
		include("sr_tracker/sh_util.lua")
		include("sr_tracker/sv_tracker.lua")

		AddCSLuaFile("sr_tracker_config.lua")
		AddCSLuaFile("sr_tracker/sh_pon.lua")
		AddCSLuaFile("sr_tracker/sh_util.lua")
		AddCSLuaFile("sr_tracker/cl_tracker.lua")

		local query = SR_Tracker.MySQL:Create("sr_tracker_times")
			query:Create("steamid", "VARCHAR(255)")
			query:Create("time", "BIGINT")
			query:Create("firstjoin", "BIGINT")
			query:Create("lastjoin", "BIGINT")
			query:PrimaryKey("steamid")
		query:Execute()
	end)

	resource.AddFile("resource/fonts/Lato-Bold.ttf")
else
	include("sr_tracker_config.lua")
	include("sr_tracker/sh_pon.lua")
	include("sr_tracker/sh_util.lua")
	include("sr_tracker/cl_tracker.lua")
end