-- some locals
local SR = SR_Tracker
local config = SR.Config
--

-- localizations
local ipairs	= ipairs
local istable	= istable
local IsValid	= IsValid
local GetHumans	= player.GetHumans

local mysql 	= SR.MySQL
local srEncode	= SR.Encode
local setPlyVar = SR.SetPlyVar

local hasMenuPermissions = SR.HasMenuPermissions
--

util.AddNetworkString("SR_Tracker.SendTimeOnJoin")
util.AddNetworkString("SR_Tracker.SendTimes")
util.AddNetworkString("SR_Tracker.ChangePage")
util.AddNetworkString("SR_Tracker.Search")
util.AddNetworkString("SR_Tracker.ResetTime")

function SR.SavePlayerTime(ply, wait)
	local query = mysql:Update("sr_tracker_times")
		query:Update("time", ply:GetFullTime())
		query:Where("steamid", ply:SteamID())
	query:Execute(wait)
end

hook.Add("PlayerInitialSpawn", "SR_Tracker.PlayerInitialSpawn", function(ply)
	local time = 0
	local steamid = ply:SteamID()
	local ostime = os.time()

	local query = mysql:Select("sr_tracker_times")
		query:Where("steamid", steamid)
		query:Callback(function(result)
			result = istable(result) && result[1]
			if (!result) then
				query = mysql:Insert("sr_tracker_times")
					query:Insert("steamid", steamid)
					query:Insert("time", time)
					query:Insert("firstjoin", ostime)
					query:Insert("lastjoin", ostime)
				query:Execute()
			else
				query = mysql:Update("sr_tracker_times")
					query:Update("lastjoin", ostime)
					query:Where("steamid", steamid)
				query:Execute()

				time = tonumber(result.time)
			end

			setPlyVar(ply, "Time", time)
			setPlyVar(ply, "JoinTime", ostime)

			net.Start("SR_Tracker.SendTimeOnJoin")
				net.WriteUInt(time, 32)
				net.WriteUInt(ostime, 32)
			net.Send(ply)
		end)
	query:Execute()
end)

timer.Create("SR_Tracker.SaveTimes", 60, 0, function()
	for _, ply in ipairs(GetHumans()) do
		if (!IsValid(ply) || !ply:IsConnected()) then return end

		SR.SavePlayerTime(ply, true)
	end
end)

hook.Add("PlayerDisconnected", "SR_Tracker.PlayerDisconnected", function(ply)
	SR.SavePlayerTime(ply)
end)

hook.Add("PlayerSay", "SR_Tracker.OpenTrackingMenu", function(ply, text)
	if (text:lower() != config.Command:lower()) then return end
	if (!hasMenuPermissions(ply)) then return end

	local limit = config.ResultsPerPage
	local query = mysql:Select("sr_tracker_times")
		query:Limit(limit)
		query:OrderByDesc("lastjoin")
		query:Callback(function(results)
			if (!istable(results) || #results < 1) then return end

			mysql:RawQuery("SELECT COUNT(*) AS `count` FROM `sr_tracker_times`", function(results2)
				local pages = results2[1].count / limit
				pages = pages != math.floor(pages) && pages + 1 || pages

				results = srEncode(results)
				local len = #results

				net.Start("SR_Tracker.SendTimes")
					net.WriteUInt(len, 32)
					net.WriteUInt(pages, 32)
					net.WriteData(results, len)
				net.Send(ply)
			end)
		end)
	query:Execute()

	return ""
end)

net.Receive("SR_Tracker.ChangePage", function(_, ply)
	if (!hasMenuPermissions(ply)) then return end

	local page = net.ReadUInt(32)

	local limit = config.ResultsPerPage
	local offset = limit * (page - 1)
	local query = mysql:Select("sr_tracker_times")
		query:Limit(limit)
		query:Offset(offset)
		query:OrderByDesc("lastjoin")
		query:Callback(function(results)
			if (!istable(results) || #results < 1) then return end

			results = srEncode(results)
			local len = #results

			net.Start("SR_Tracker.ChangePage")
				net.WriteUInt(len, 32)
				net.WriteData(results, len)
			net.Send(ply)
		end)
	query:Execute()
end)

net.Receive("SR_Tracker.Search", function(_, ply)
	if (!hasMenuPermissions(ply)) then return end

	local query = mysql:Select("sr_tracker_times")
		query:Where("steamid", net.ReadString())
		query:Callback(function(results)
			if (!istable(results) || #results < 1) then return end

			results = srEncode(results)
			local len = #results

			net.Start("SR_Tracker.Search")
				net.WriteUInt(len, 32)
				net.WriteData(results, len)
			net.Send(ply)
		end)
	query:Execute()
end)

net.Receive("SR_Tracker.ResetTime", function(_, ply)
	if (!hasMenuPermissions(ply)) then return end

	local steamid = net.ReadString()

	local ply2 = player.GetBySteamID(steamid)
	if (ply2) then
		local query = mysql:Update("sr_tracker_times")
			query:Update("time", 0)
			query:Where("steamid", steamid)
		query:Execute()

		setPlyVar(ply2, "Time", 0)
		setPlyVar(ply2, "JoinTime", os.time())

		net.Start("SR_Tracker.ResetTime")
		net.Send(ply2)
	else
		local query = mysql:Delete("sr_tracker_times")
			query:Where("steamid", steamid)
		query:Execute()
	end
end)