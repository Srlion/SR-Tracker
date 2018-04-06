--
	local sr = SR_Tracker
	local config = sr.Config
--

--
	local mysql = sr.MySQL
--

function sr.SetPlayerVar(ply, key, value)
	ply.SR_Tracker[key] = value
end

function sr.GetPlayerVar(ply, key)
	return ply.SR_Tracker[key]
end