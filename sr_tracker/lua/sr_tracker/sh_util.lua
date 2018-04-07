--
	local sr = SR_Tracker
	local config = sr.Config
	local menupermissions = config.MenuPermissions
--

--
	local CurTime = CurTime
	local util = util
	local hook_Add = hook.Add
	local hook_Call = hook.Call
	local hook_Remove = hook.Remove
--

function sr.CreatePlayerTable(ply)
	ply.SR_Tracker = {}
end

function sr.SetPlayerVar(ply, key, value, value2)
	if (value2) then
		ply.SR_Tracker[key][value] = value2
	else
		ply.SR_Tracker[key] = value
	end
end

function sr.GetPlayerVar(ply, key, key2)
	local value = ply.SR_Tracker[key]

	if (key2) then
		value = value[key2]
	end

	return value
end

function sr.Encode(data)
	return util.Compress(sr.pon.encode(data))
end

function sr.Decode(data)
	return sr.pon.decode(util.Decompress(data))
end

function sr.HasMenuPermissions(ply)
	if (menupermissions[ply:GetUserGroup()] || menupermissions[ply:SteamID()] || menupermissions[ply:SteamID64()]) then
		return true
	end

	return false
end

function sr.HookCall(key, ...)
	local Hook = "SR_Tracker." .. key

	hook_Call(Hook, nil, ...)
end

function sr.PlayerHookCall(ply, key, ...)
	local Hook = "SR_Tracker." .. key .. ply:SteamID()

	hook_Call(Hook, nil, ...)
end

function sr.RemoveHook(key, ide)
	local Hook = "SR_Tracker." .. key

	hook_Remove(Hook, ide)
end

function sr.RemovePlayerHook(ply, key, ide)
	local Hook = "SR_Tracker." .. key .. ply:SteamID()

	hook_Remove(Hook, ide)
end

function sr.AddHook(key, ide, callback)
	local Hook = "SR_Tracker." .. key

	hook_Add(Hook, ide, function(...)
		callback(...)
	end)
end

function sr.AddPlayerHook(ply, key, ide, callback)
	local Hook = "SR_Tracker." .. key .. ply:SteamID()

	hook_Add(Hook, ide, function(...)
		callback(...)
	end)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetFullTime()
	return sr.GetPlayerVar(self, "Time") + (CurTime() - sr.GetPlayerVar(self, "JoinTime"))
end

function PLAYER:GetSessionTime()
	return CurTime() - sr.GetPlayerVar(self, "JoinTime")
end