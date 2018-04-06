--
	SR_Tracker = {}
	SR_Tracker.Config = {}
--

--
	local sr = SR_Tracker
	local config = sr.Config
--

if (SERVER) then
	include("sr_tracker_config.lua")
	include("sr_tracker/sv_util.lua")
	include("sr_tracker/sv_tracker.lua")
	include("sr_tracker/sv_mysql.lua")

	AddCSLuaFile("sr_tracker_config.lua")
	AddCSLuaFile("sr_tracker/cl_util.lua")
	AddCSLuaFile("sr_tracker/cl_tracker.lua")

	hook.Add("SR_Tracker.DatabaseConnected", "SR_Tracker.Initialize", function()
		include("sr_tracker/sv_initialize.lua")
	end)
else
	include("sr_tracker_config.lua")
	include("sr_tracker/cl_util.lua")
	include("sr_tracker/cl_tracker.lua")
end
