--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	local mysql = sr.MySQL
--

hook.Add("PlayerInitialSpawn", "SR_Tracker.PlayerInitialSpawn", function(ply)
	ply.SR_Tracker = {}

	local steamid = ply:SteamID()

	local query = mysql:Select("sr_staff_manager_player_info")
		query:Where("steamid", steamid)
		query:Callback(function(result)
			local result = result && result[1]
			if (!result) then
				local query = mysql:Insert("sr_staff_manager_player_info")
					query:Insert("steamid", steamid)
					query:Insert("time", 0)
				query:Execute()
			else
				print("hi")
			end
		end)
	query:Execute()
end)
