--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	local istable = istable
	local isnumber = isnumber
	local mysql = sr.MySQL
--

function sr.GetTimes(ply)
	local limit = config.ResultsPerPage
	local query = mysql:Select("sr_tracker_times")
		query:Limit(limit)
		query:Callback(function(result)
			if (istable(result) && #result > 0) then
				mysql:RawQuery("SELECT COUNT(*) AS `count` FROM `sr_tracker_times`;", function(result2)
					local pages = result2[1].count / limit
					if (pages != math.floor(pages)) then
						pages = math.floor(pages) + 1
					end

					sr.SetPlayerVar(ply, "CachedPages", {})
					sr.SetPlayerVar(ply, "CachedSearches", {})
					sr.SetPlayerVar(ply, "CachedPages", 1, result)
					sr.PlayerHookCall(ply, "SendingTimes", result, pages)
				end)
			end
		end)
	query:Execute()
end

function sr.ChangePage(ply, page)
	local cachedpage = sr.GetPlayerVar(ply, "CachedPages", page)
	if (cachedpage) then
		return sr.PlayerHookCall(ply, "SendNewPage", cachedpage)
	end

	local limit = config.ResultsPerPage
	local offset = limit * (page - 1)
	local query = mysql:Select("sr_tracker_times")
		query:Limit(limit)
		query:Offset(offset)
		query:Callback(function(result)
			if (istable(result) && #result > 0) then
				sr.SetPlayerVar(ply, "CachedPages", page, result)
				sr.PlayerHookCall(ply, "SendNewPage", result)
			end
		end)
	query:Execute()
end

function sr.Search(ply, steamid)
	local cachedsearch = sr.GetPlayerVar(ply, "CachedSearches", steamid)
	if (cachedsearch) then
		return sr.PlayerHookCall(ply, "Search", cachedsearch)
	end

	local query = mysql:Select("sr_tracker_times")
		query:Where("steamid", steamid)
		query:Callback(function(result)
			if (istable(result) && #result > 0) then
				sr.SetPlayerVar(ply, "CachedSearches", steamid, result)
				sr.PlayerHookCall(ply, "Search", result)
			end
		end)
	query:Execute()
end

function sr.ResetTime(steamid)
	local query = mysql:Update("sr_tracker_times")
		query:Update("time", 0)
		query:Where("steamid", steamid)
	query:Execute()

	local ply = player.GetBySteamID(steamid)
	if (ply) then
		sr.SetPlayerVar(ply, "Time", 0)
		sr.SetPlayerVar(ply, "JoinTime", CurTime())

		net.Start("SR_Tracker.ResetTime")
		net.Send(ply)
	end
end
