--
	SR_Tracker = {}
	SR_Tracker.Config = {}
--

--
	local sr = SR_Tracker
	local config = sr.Config
--

if (SERVER) then
	include("sr_tracker/sv_mysql.lua")

	hook.Add("SR_Tracker.DatabaseConnected", "SR_Tracker.Initialize", function()
		include("sr_tracker_config.lua")
		include("sr_tracker/sh_util.lua")
		include("sr_tracker/sh_pon.lua")
		include("sr_tracker/sv_util.lua")
		include("sr_tracker/sv_tracker.lua")
		include("sr_tracker/sv_initialize.lua")

		AddCSLuaFile("sr_tracker_config.lua")
		AddCSLuaFile("sr_tracker/sh_util.lua")
		AddCSLuaFile("sr_tracker/sh_pon.lua")
		AddCSLuaFile("sr_tracker/cl_util.lua")
		AddCSLuaFile("sr_tracker/cl_tracker.lua")
	end)
else
	include("sr_tracker_config.lua")
	include("sr_tracker/sh_util.lua")
	include("sr_tracker/sh_pon.lua")
	include("sr_tracker/cl_util.lua")
	include("sr_tracker/cl_tracker.lua")
end