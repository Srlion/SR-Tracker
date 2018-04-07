--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	local mysql = sr.MySQL
	local CurTime = CurTime
--

hook.Add("PlayerInitialSpawn", "SR_Tracker.PlayerInitialSpawn", function(ply)
	local time = 0
	local steamid = ply:SteamID()
	local curtime = CurTime()
	local ostime = os.time()

	local query = mysql:Select("sr_tracker_times")
		query:Where("steamid", steamid)
		query:Callback(function(result)
			local result = istable(result) && result[1]
			if (!result) then
				local query = mysql:Insert("sr_tracker_times")
					query:Insert("steamid", steamid)
					query:Insert("time", time)
					query:Insert("firstjoin", ostime)
					query:Insert("lastjoin", ostime)
				query:Execute()
			else
				local query = mysql:Update("sr_tracker_times")
					query:Update("lastjoin", ostime)
					query:Where("steamid", steamid)
				query:Execute()

				time = tonumber(result.time)
			end

			sr.CreatePlayerTable(ply)
			sr.SetPlayerVar(ply, "JoinTime", curtime)
			sr.SetPlayerVar(ply, "Time", time)

			net.Start("SR_Tracker.SendTime")
				net.WriteFloat(time)
			net.Send(ply)

			timer.Create("SR_Tracker." .. steamid, 60, 0, function()
				if (IsValid(ply)) then
					local time = ply:GetFullTime()

					local query = mysql:Update("sr_tracker_times")
						query:Update("time", time)
						query:Where("steamid", steamid)
					query:Execute(true)
				end
			end)
		end)
	query:Execute()
end)

hook.Add("PlayerDisconnected", "SR_Tracker.PlayerDisconnected", function(ply)
	timer.Remove("SR_Tracker." .. ply:SteamID())
end)

hook.Add("PlayerSay", "SR_Tracker.OpenTrackingMenu", function(ply, text)
	if (string.lower(text) == string.lower(config.Command)) then
		if (sr.HasMenuPermissions(ply)) then
			sr.AddPlayerHook(ply, "SendingTimes", "SendingTimesToPlayer", function(results, pages)
				local results = sr.Encode(results)
				local len = #results

				net.Start("SR_Tracker.SendTimes")
					net.WriteUInt(len, 32)
					net.WriteUInt(pages, 32)
					net.WriteData(results, len)
				net.Send(ply)
			end)

			sr.GetTimes(ply)
		end

		return ""
	end
end)

net.Receive("SR_Tracker.ChangePage", function(_, ply)
	local page = net.ReadUInt(32)

	if (sr.HasMenuPermissions(ply)) then
		sr.AddPlayerHook(ply, "SendNewPage", "SendNewPage", function(results)
			local results = sr.Encode(results)
			local len = #results

			net.Start("SR_Tracker.ChangePage")
				net.WriteUInt(len, 32)
				net.WriteData(results, len)
			net.Send(ply)
		end)

		sr.ChangePage(ply, page)
	end
end)

net.Receive("SR_Tracker.Search", function(_, ply)
	local steamid = net.ReadString()

	if (sr.HasMenuPermissions(ply)) then
		sr.AddPlayerHook(ply, "Search", "Search", function(results)
			local results = sr.Encode(results)
			local len = #results

			net.Start("SR_Tracker.Search")
				net.WriteUInt(len, 32)
				net.WriteData(results, len)
			net.Send(ply)
		end)

		sr.Search(ply, steamid)
	end
end)

net.Receive("SR_Tracker.ResetTime", function(_, ply)
	local steamid = net.ReadString()

	if (sr.HasMenuPermissions(ply)) then
		sr.ResetTime(steamid)
	end
end)