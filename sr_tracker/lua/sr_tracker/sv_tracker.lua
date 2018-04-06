--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	local mysql = sr.MySQL
	local CurTime = CurTime
--

hook.Add("PlayerInitialSpawn", "SR_Tracker.PlayerInitialSpawn", function(ply)
	ply.SR_Tracker = {}

	local time = 0
	local steamid = ply:SteamID()
	local curtime = CurTime()

	local query = mysql:Select("sr_tracker_times")
		query:Where("steamid", steamid)
		query:Callback(function(result)
			local result = istable(result) && result[1]

			if (!result) then
				local query = mysql:Insert("sr_tracker_times")
					query:Insert("steamid", steamid)
					query:Insert("time", 0)
					query:Insert("firstjoin", curtime)
					query:Insert("lastjoin", curtime)
				query:Execute()
			else
				local query = mysql:Update("sr_tracker_times")
					query:Update("lastjoin", curtime)
					query:Where("steamid", steamid)
				query:Execute()

				time = tonumber(result.time)
			end

			sr.SetPlayerVar(ply, "jointime", curtime)
			sr.SetPlayerVar(ply, "time", time)

			timer.Create("SR_Tracker." .. steamid, 60, 0, function()
				if (IsValid(ply)) then
					local time = sr.GetPlayerVar(ply, "time") + (CurTime() - sr.GetPlayerVar(ply, "jointime"))

					local query = mysql:Update("sr_tracker_times")
						query:Update("time", time)
						query:Where("steamid", steamid)
					query:Execute()
				end
			end)

			net.Start("SR_Tracker.SendTime")
				net.WriteFloat(time)
			net.Send(ply)
		end)
	query:Execute()
end)


hook.Add("PlayerDisconnected", "SR_Tracker.PlayerDisconnected", function(ply)
	timer.Remove("SR_Tracker." .. ply:SteamID())
end)